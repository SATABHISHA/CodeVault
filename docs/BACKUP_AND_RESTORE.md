# Backup and Restore

## Windows local workflow

An authorized local administrator can export an encrypted, versioned archive containing a manifest, schema version, checksums, application data, and optional assets. Restore first validates signature/checksum, compatibility, free space, and credentials and creates a safety snapshot.

- Merge imports by stable UUID and explicit per-entity conflict policy, producing a preview and result report.
- Replace restores into a new database, runs integrity checks, then atomically switches databases. The prior database remains recoverable until retention expiry.

No Windows screen or service may request or execute cloud backup/restore.

## Android/Web request workflow

A permitted tenant user submits the required contact, device, scope, reason/notes, and restore preference. Laravel derives tenant/company, creates an immutable request timeline, and queues SMTP notification to `wecare@ahanova.in`. Requesters can track status but cannot approve or execute.

Only a Super-Superadmin may approve and execute. Execution requires recent authentication, reason, explicit target/scope confirmation, maintenance controls, encrypted artifact storage, checksum verification, audit events, and notifications. Restore requires a pre-restore backup and increments the tenant generation after validation.

Request states: `submitted -> triaged -> approved|rejected -> scheduled -> running -> validating -> completed|failed|cancelled`. State transitions are server-enforced and idempotent. Artifact credentials and storage configuration remain outside the database backup and source control.

Recovery objectives, retention, storage provider, geographic requirements, and approval separation require stakeholder decisions before implementation.
