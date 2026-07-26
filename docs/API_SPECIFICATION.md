# API Specification

OpenAPI 3.1 will be the contract source under the Laravel repository. JSON uses `snake_case`, UUID strings, ISO-8601 UTC timestamps, pagination links/cursors, and a stable error envelope: `code`, `message`, `details`, `correlation_id`.

## Endpoint map (`/api/v1`)

| Area | Representative endpoints |
|---|---|
| Auth | `POST /auth/login`, `/auth/logout`, `/auth/refresh`, `/auth/change-password`; `GET /me` |
| Membership | `GET /me/memberships`; `POST /me/active-membership` |
| Tenancy | CRUD `/tenants`, `/subtenants`, `/memberships`, `/role-assignments` (scoped) |
| Masters | CRUD `/companies`, `/users`, `/parts`, `/ports`, `/printers` |
| Labels | CRUD `/label-templates`; publish `/label-templates/{id}/versions`; CRUD `/code-rules` |
| Printing | `POST /print-jobs`; `GET /print-jobs/{id}` and `/print-history` |
| Sync | `POST /sync/push`; `GET /sync/pull?cursor=`; `GET /sync/bootstrap`; `GET /sync/generation` |
| Support | CRUD `/support-requests`; messages under each request |
| Backup/restore | `POST /backup-restore-requests`; tenant-scoped list/show/cancel |
| Platform backup | `POST /platform/backup-restore-requests/{id}/approve|reject|execute` |
| Billing | read plans/subscription/invoices; payment initiation and verified webhook endpoints |
| Reports | `POST /report-jobs`; `GET /report-jobs/{id}` and signed download |
| Platform admin | scoped tenant, assignment, SMTP, subscription, audit, and operations endpoints |

Mutations accept `Idempotency-Key`; concurrency uses record `version` or `If-Match`. Validation failures return 422, unauthenticated 401, forbidden 403, missing 404, conflict/version mismatch 409, throttled 429. Bulk and sync endpoints impose item and byte limits.

Cloud backup/restore request input includes company/tenant context derived server-side plus contact name, email, phone, platform/device, requested scope, merge/replace preference (restore), reason, and notes. Creation writes the request and outbox email atomically; SMTP delivery is queued.
