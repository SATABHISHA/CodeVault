# Android/Web synchronization, conflicts, and restore alignment

Laravel/MySQL is authoritative for Android and Web. Windows is deliberately excluded and remains locally authoritative. The shared Flutter engine uses Drift only for tenant-scoped cache, outbox, conflicts, cursors, offline print logs, previews, managed-request drafts, and alignment reports.

## HTTP APIs

All endpoints require Sanctum, a changed password, tenant authorization, the required permission, and an `X-Device-UUID` belonging to the authenticated user and selected tenant.

| Method | Endpoint | Contract |
|---|---|---|
| `GET` | `/api/v1/tenants/{tenant}/sync/generation` | Returns authoritative generation plus the current device's outstanding alignment job. Requires `parts.read`. |
| `POST` | `/api/v1/tenants/{tenant}/sync/push` | Accepts generation and 1–100 UUID mutations for `part` or immutable `print_log`. Each mutation has its own UUID idempotency key and optional base version. Requires `parts.write`. |
| `GET` | `/api/v1/tenants/{tenant}/sync/pull?generation=&cursor=&per_page=` | Returns ordered parts, delete tombstones, and immutable print logs. Cursor is opaque, generation-bound, and limited to 100 records. Requires `parts.read`. |
| `GET` | `/api/v1/tenants/{tenant}/alignment` | Returns the device alignment job created by a restore. |
| `POST` | `/api/v1/tenants/{tenant}/alignment/{alignment}/acknowledge` | Confirms that the client safety export and authoritative replacement completed for the target generation. |

The OpenAPI source in the Laravel repository documents request fields and response envelopes.

## Push rules

- Create uses a client UUID. An exact existing record is accepted as a duplicate; different data creates a conflict.
- Update/delete requires the current `base_version`. Changed-on-both-sides creates a persisted open conflict and leaves the server record unchanged.
- Part deletes are soft deletes and pull as tombstones.
- Print logs are append-only. Update/delete is rejected as `immutable_record`, and their referenced print job must belong to the tenant.
- Idempotency records store a request hash and prior result. Repeating the same key and payload returns the original result; reusing a key for different content creates a conflict.
- Unsupported entities or operations are conflicts rather than arbitrary model writes.
- Finalized invoices, audit logs, billing data, and sequence counters are not syncable through this API.

Online code/serial allocation stays in Laravel's transactional print-job service. Offline clients must use visibly temporary values and must not upload them as authoritative sequence state. They reconcile by creating/identifying the authoritative server print job before appending its offline print log.

## Client states and recovery

Local records/outbox use `pending_create`, `pending_update`, `pending_delete`, `synced`, `conflict`, `failed`, and `blocked_by_alignment`. Retryable transport failures use bounded exponential backoff. Validation, permission, immutable-record, and version conflicts remain visible for review instead of looping silently.

Safe conflict choices are:

- `keep_server`: resolve the local conflict without another mutation.
- `discard_local`: explicitly abandon the local value.
- `reapply_local`: create a new update based on the returned server version; it is still subject to normal authorization and conflict checks.

## Restore alignment sequence

1. Generation discovery reports the newer generation or an outstanding alignment job.
2. The client refuses destructive alignment unless an `AlignmentSafetyExporter` is configured.
3. A tenant/generation/checksum-protected `.cvbackup` safety export is created.
4. Pending mutations are quarantined in the local conflict review queue as `tenant_generation_changed`.
5. Stale cache/outbox/cursor is replaced and the authoritative generation is pulled page by page.
6. The client records its result report and acknowledges the Laravel alignment job.
7. Push resumes only after acknowledgement.

If the generation changes during a pull, the engine stops and requires a fresh safety-export alignment rather than continuing with a mixed-generation cache.

## Prompt 10 closure

Drift schema version 2 adds dedicated browser/local tables for label previews and managed-request drafts, plus offline print logs and detailed alignment metadata. Portable browser exports now include these records. The Web build packages the official SQLite Wasm runtime and compiled Drift worker. Automated VM tests cover the persistence schema and export behavior; the Chrome test harness remains available for deployment validation, where HTTPS, Wasm MIME, worker delivery, browser quota, and cross-origin isolation can be tested together.

## Tests and operations

Laravel tests cover duplicate push/idempotency, cursor pagination, tombstones, changed-on-both-sides conflict retention, stale generation, safety-export instruction, and cross-tenant device rejection. Existing restore tests cover generation increments, device alignment job creation, stale mutation blocking, and acknowledgement boundaries. Flutter tests cover queueing, retry, conflicts, safe resolution, generation replacement, required safety export, tenant cache identity, and browser export validation.

Idempotency/conflict retention needs a scheduled production policy after audit/legal requirements are agreed. Physical offline print reconciliation must be acceptance-tested with supported devices, and production clients must persist a stable server-issued device UUID.
