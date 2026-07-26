# Test Plan

## Quality gates

Laravel: formatter, static analysis, migration up/down checks on an isolated database, unit tests, feature/API tests, OpenAPI validation, and dependency audit. Flutter: formatter, analyzer, unit/widget/golden tests, Drift migration tests, integration tests on Windows/Android/Web, and release builds.

## Critical suites

- Authentication/session expiry, password change, revocation, and local Windows login.
- Role/permission matrix and exhaustive cross-tenant access denial, including jobs, reports, storage, and route binding.
- Schema constraints, money/tax rounding, immutable template versions, soft delete/tombstones.
- Offline create/update/delete, ordering, retries, idempotency, conflicts, cursor recovery, generation mismatch, and browser storage eviction.
- Backup request authorization/state machine/email outbox; owner-only execution; encrypted Windows merge/replace and rollback.
- Printer layout goldens, adapters, failure/retry semantics, and physical devices.
- API contract, validation/error envelope, pagination, rate limits, and backward compatibility.
- Security tests for CSRF/CORS, injection, upload handling, signed URLs, webhook signatures, secret/log redaction.

CI uses no production credentials and disposable databases. Destructive restore tests run only in isolated fixtures. Performance targets and supported OS/browser/device/printer matrices must be agreed before acceptance thresholds are fixed.

Prompt 01 verification is documentation-only: link/file presence and Git diff review. There is no application code to format, analyze, migrate, test, or build yet.
