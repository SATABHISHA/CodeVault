# Offline and Sync

Windows never syncs. Its local database is authoritative for the installation.

Android and Web use an outbox/inbox protocol:

1. Write the local entity and outbox operation in one local transaction.
2. Push ordered, dependency-aware batches with operation UUID and base server version.
3. Laravel authenticates scope, validates permission, deduplicates operation UUID, applies a transaction, increments version, and records a change.
4. Client pulls cursor-based changes including tombstones, applies them transactionally, then advances its cursor.
5. Retry transient failures with bounded exponential backoff; validation/authorization failures require user action.

The default conflict rule is server-authoritative optimistic concurrency. Non-overlapping safe fields may be merged by an explicit entity policy; templates, permissions, billing, and backup operations never auto-merge. Conflicts retain both payloads for review.

Each tenant has a monotonic `generation`. A successful cloud restore increments it. On mismatch, clients stop pushing, quarantine pending operations, clear/rebuild the cloud working copy, and offer controlled reapplication of valid pending work. Never silently replay against a restored generation.

Initial bootstrap is paged, resumable, checksummed, and bounded by membership scope. Tokens/cursors are opaque and expire by policy. Web persistence capability is checked at startup; loss/eviction is recoverable by bootstrap. Connectivity state is advisory—failed requests determine offline behavior.
