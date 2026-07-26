# Deployment

Environments are development, testing/staging, and production with separate databases, storage, SMTP, payment credentials, signing keys, and API origins. Configuration is injected through environment variables/secret management; Flutter receives only non-secret compile-time configuration.

Laravel deployment is an immutable artifact with locked dependencies: maintenance/readiness checks, database backup, forward-compatible migration, application release, queue worker restart, scheduler verification, smoke tests, and rollback decision. Migrations follow expand/migrate/contract across releases; rollback never assumes an irreversible schema downgrade.

Flutter Windows is signed and packaged with the required SQLite runtime. Android uses signed app bundles with protected signing material. Web uses hashed static assets, HTTPS, correct WASM/worker MIME types and headers, and an explicit service-worker/cache migration strategy. API and local schema compatibility are versioned across staggered client releases.

Operations require centralized structured logs, metrics, traces/correlation IDs, health/readiness endpoints, queue/dead-letter monitoring, backup verification, restore drills, alert ownership, release notes, and incident runbooks.

Unresolved deployment inputs: hosting/cloud provider, regions, domains, SLA/RPO/RTO, CI/CD system, mobile distribution channel, Windows installer/update mechanism, supported browsers/OS versions, and observability vendors.
