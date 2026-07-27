# Flutter Web, Drift browser storage, printing, and managed requests

Flutter Web is a Laravel API client. Laravel/MySQL remains authoritative; the browser database is a tenant-scoped cache and outbox, not an unrestricted native SQLite file.

## Browser persistence

`AndroidCacheDatabase.forWeb` reuses the shared Drift cache schema and opens `WasmDatabase` with `web/sqlite3.wasm` and the compiled `web/drift_worker.js`. The database name contains only the validated tenant UUID. Drift selects the strongest available browser persistence implementation and may fall back depending on browser capabilities. Cached parts, pending mutations, conflicts, cursors/generation, print state, and future preview/request-draft rows remain local to that browser profile.

Production hosting must serve `.wasm` as `application/wasm`, use HTTPS, and preserve the worker asset. Cross-origin isolation headers (`Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`) are recommended where compatible with hosting and third-party assets. Private/incognito browsing, site-data clearing, quotas, or storage eviction can remove local data; the UI therefore provides a portable `.cvbackup` export.

Exports contain a manifest, schema/generation, tenant identity, SHA-256 checksum, cached tenant rows, and pending mutations. Import rejects corrupt archives, other tenants, and stale generations. It adds only absent cached rows and quarantines imported mutations as conflicts requiring review, so it cannot silently overwrite MySQL.

## Authentication, tenancy, and permissions

Sanctum bearer tokens are held through `flutter_secure_storage` (WebCrypto-backed web storage requires HTTPS). `/me` supplies the mandatory tenant and role permissions. A 401 deletes the local token and exposes a session-expiry callback. Backup and restore actions are independently hidden unless the server grants `backup_requests.create` or `restore_requests.create`. Every browser database and API route is tenant-scoped.

## Consumed Laravel APIs

| Method | Endpoint | Flutter Web use |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Login with `login`, `password`, `device_name`, and `platform=web`; stores the returned Sanctum token. |
| `GET` | `/api/v1/me` | Resolves user ID, tenant ID, roles, and permissions. |
| `POST` | `/api/v1/auth/logout` | Revokes the active token, then removes it locally. |
| `POST` | `/api/v1/tenants/{tenant}/managed-requests` | Sends backup/restore type, contact details, phone, requested scope, browser/device metadata, reason, notes, and restore preference. Laravel persists the request and queues SMTP to `wecare@ahanova.in`. Flutter has no execution endpoint. |
| `GET` | `/api/v1/tenants/{tenant}/sync/generation` | Reads the authoritative generation and device alignment state. |
| `POST` | `/api/v1/tenants/{tenant}/sync/push` | Pushes UUID/idempotency-key mutations with base version and generation. |
| `GET` | `/api/v1/tenants/{tenant}/sync/pull?generation=&cursor=` | Pulls versioned tenant changes, tombstones and the next cursor. |

The auth, `/me`, logout, managed-request, and tenant sync APIs exist in Laravel. Direct browser-to-MySQL access is prohibited.

## Local application APIs

- `WebLocalExportService.export/import`: portable, integrity-checked browser cache transfer with tenant/generation enforcement.
- `BrowserPdfGenerator.generate`: creates a PDF with an exact millimetre page size.
- `BrowserPrintGateway.showPrintDialog/download`: browser print dialog and PDF download/share boundary.
- `LocalPrintAgentGateway`: future-only pairing, revocation, signed-job submission, and status contract. No localhost agent is enabled.
- `ManagedRequestService.submit`: request creation only; it cannot execute backup or restore.

## Printing constraints

The Web screen generates a label preview PDF, opens the browser print dialog, and downloads the PDF. Users must select Actual size/100%, disable added margins, and verify orientation. Browsers and drivers can still scale output. CodeVault does not claim that arbitrary ZPL, TSPL, or ESC/POS can be sent directly from every browser.

A future local agent must require tenant/device pairing, short-lived signed jobs, replay protection, revocable credentials, status reporting, and audit logs. It must bind only to an explicitly reviewed localhost origin and never accept unsigned raw commands.

## Deployment and residual risks

- Validate Wasm/worker caching and MIME/header configuration on the production origin and service worker.
- Test persistence, quotas, eviction, PDF sizing, and downloads on the supported browser matrix.
- SMTP delivery is owned and tested by Laravel; Flutter verifies only request submission and never reports email success independently.
- Physical-size printing requires real browser/driver/printer acceptance tests.
- Validate sync throughput, retention, and restore alignment on production-like data before rollout.

## Validation

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --debug
flutter build apk --debug
flutter build windows --release
```
