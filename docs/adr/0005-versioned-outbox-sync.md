# ADR-0005: Versioned outbox and cursor sync

Status: Accepted

Android and Web use transactional local outboxes, idempotent push operations, optimistic record versions, cursor-based pulls, tombstones, and tenant generations. Laravel is the conflict authority. A restore generation mismatch forces controlled rebootstrap and quarantines pending work. Timestamp-only last-write-wins is rejected because clock skew and silent data loss are unacceptable.
