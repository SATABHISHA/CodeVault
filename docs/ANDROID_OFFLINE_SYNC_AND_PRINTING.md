# Android offline sync and wireless printing

Android uses Laravel/MySQL as the only authoritative server. Each tenant gets a UUID-only application-support directory and Drift database containing cached parts, pending mutations, conflicts, cursors, printer profiles, and local print-job state. Windows local authority behavior is unchanged.

## Consumed Laravel APIs

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Sanctum login using `login`, `password`, `device_name`, and `platform=android`; token is stored with secure storage. |
| `GET` | `/api/v1/me` | Resolves the authenticated user and mandatory tenant context. |
| `POST` | `/api/v1/auth/logout` | Revokes the active Sanctum token before local deletion. |
| `POST` | `/api/v1/tenants/{tenant}/managed-requests` | Submits backup/restore request contact, scope, platform/device, reason, notes and restore preference. Laravel creates the request and queues SMTP. The Flutter client has no execute API. |
| `GET` | `/api/v1/sync/generation?tenant_id=` | Retrieves the current tenant generation before push/pull. |
| `POST` | `/api/v1/sync/push` | Pushes UUID mutations with base version, generation and per-item idempotency key. |
| `GET` | `/api/v1/sync/pull?tenant_id=&cursor=` | Pulls a versioned page and next cursor. |

The first four endpoints exist in the current Laravel repository. The three `/sync/*` endpoints are required by the architecture but are not currently registered by Laravel. `DioSyncGateway` documents and implements the client contract, while production synchronization must remain disabled until those backend endpoints are delivered. It must not fall back to direct MySQL access.

## Local application APIs

- `SyncEngine.queue`: adds a tenant-keyed UUID mutation and UUID idempotency key without requiring connectivity.
- `SyncEngine.synchronize`: checks connectivity, compares generation, pushes eligible outbox rows, applies retry backoff, records version conflicts, and consumes pull cursors.
- `SyncRemoteGateway.generation`, `push`, and `pull`: testable server boundary implemented by `DioSyncGateway`.
- `AndroidLocalExportService.export`: creates a device-local `.cvbackup` cache export for an Android document path.
- `AndroidLocalExportService.verify`: validates tenant, generation, ZIP integrity, and SHA-256 before a local merge/replace workflow. Stale generations are rejected so local data cannot override restored server data.
- `PrinterDiscoveryService`: discovers transport-specific devices.
- `PrinterConnectionService`: connects, disconnects, and tests a printer.
- `PrinterLanguageAdapter`: encodes ESC/POS, TSPL/TSPL2, ZPL, EPL, CPCL, EZPL, PDF or raster content.
- `LabelRasterizer`: renders a label into device dots for raster/system printing.
- `PrintTransport`: isolates Bluetooth Classic, BLE, Wi-Fi/LAN, TCP, Android system print, vendor SDK, and USB OTG transports.
- `PrintJobRepository`: persists job ID and delivery state.
- `WirelessPrinterService.print`: suppresses completed duplicates and requires explicit confirmation before retrying an uncertain send.

## Tenant and restore alignment

Every cached row has `tenant_id` in its primary identity. A generation change quarantines pending edits as conflicts, clears stale cached rows/outbox entries, resets the cursor, and pulls the restored generation. Imports from another tenant or generation are rejected.

## Permissions

Android 12+ requests `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` only for Bluetooth workflows. Older Bluetooth discovery uses location only through SDK 30. Android 13+ Wi-Fi discovery uses `NEARBY_WIFI_DEVICES`. Raw TCP and system printing do not request unrelated location or broad storage permissions. USB host support is optional.

## Validation and builds

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
```

Physical Bluetooth, vendor SDK, USB, and model-specific language acceptance still require representative hardware. Release APK signing must use a protected production keystore; debug signing is not a production artifact.
