# Security

Baseline controls:

- Sanctum authentication, short-lived/revocable sessions as appropriate, secure cookie policy for Web, CSRF protection, and token storage appropriate to each platform.
- Adaptive password hashing, password change on seeded development owner, rate limits for authentication/export/sync, and optional MFA design before production owner access.
- Deny-by-default policies and tenant-scoped route binding/querying; automated cross-tenant negative tests.
- TLS, strict CORS allowlist, security headers, request size limits, validation DTOs, parameterized ORM queries, and output encoding.
- UUID public identifiers; opaque signed, expiring download URLs; malware/content checks for uploads.
- Secrets only in environment/secret managers. SMTP, API, signing, and encryption keys are redacted and rotatable.
- Immutable append-oriented audit for login, permission, tenant, billing, backup/restore, export, and platform-owner actions, including actor, scope, correlation ID, before/after summary, IP/device, and reason.
- Dependency scanning, static analysis, secret scanning, SBOM/release provenance, protected branches, reviewed migrations, and tested restore procedures.

The development Super-Superadmin seeder must refuse to run outside local/development, use the specified temporary credentials, hash the password, and set `must_change_password = true`. Production must not contain a default credential path.

Threat-model priorities are tenant escape, stolen device/token, malicious sync payload, backup exfiltration, restore misuse, template injection, unsafe printer commands, payment webhook forgery, SMTP abuse, and sensitive data in logs. A DPIA/data classification and retention policy remain required.
