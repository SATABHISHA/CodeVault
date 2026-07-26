# Database Design

This is a proposed logical schema; migrations do not yet exist.

## Cloud/MySQL groups

- Identity: `users`, `password_reset_tokens`, `personal_access_tokens`, `devices`, `sessions`.
- Tenancy: `tenants`, `subtenants`, `memberships`, `superadmin_tenant_assignments`, `roles`, `permissions`, role/permission pivots.
- Operations: `companies`, `parts`, `ports`, `printers`, `label_templates`, `label_template_versions`, `code_rules`, `print_jobs`, `print_events`.
- Commercial: `plans`, `subscriptions`, `invoices`, `invoice_items`, `payments`, `tax_profiles`.
- Service: `support_requests`, `support_messages`, `backup_restore_requests`, `backup_artifacts`, `smtp_profiles`.
- Control: `sync_changes`, `sync_cursors`, `idempotency_keys`, `audit_logs`, `outbox_messages`, `report_jobs`.

Tenant-owned rows include `id` (UUID), `tenant_id`, optional `subtenant_id`, `version` (positive integer), `created_at`, `updated_at`, optional `deleted_at`, and actor metadata where required. Money uses integer minor units plus ISO currency. Template definitions are versioned immutable JSON validated against a schema; published versions are never edited in place.

Indexes begin with scope: e.g. `(tenant_id, updated_at, id)`, `(tenant_id, external_code)`, and `(tenant_id, deleted_at)`. Uniqueness is scoped. Referential deletion is restricted for financial/audit data and soft deletion is used for syncable masters.

## Local Drift groups

Shared cloud-working tables mirror sync fields plus `sync_state`, `server_version`, and `last_synced_at`. An `outbox` stores operation ID, entity, record ID, base version, canonical payload, dependency IDs, attempts, and state. `sync_metadata` stores cursor and tenant generation.

Windows additionally stores local users/roles, company configuration, all operational masters, encrypted credential material, backup history, and authoritative print history. It does not store cloud backup requests.

## Retention and encryption

Passwords use Laravel's configured adaptive hasher; local password verifiers use a modern memory-hard KDF supported by the chosen package. Secrets use OS secure storage or application-level envelope encryption, not plain SQLite fields. Audit and financial retention periods require business/legal confirmation. Database backups are encrypted, checksummed, and assigned expiry metadata.
