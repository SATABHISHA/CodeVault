# ADR-0004: Server-derived tenant context

Status: Accepted

Laravel derives tenant scope from authenticated membership and verifies every operation with policies/query boundaries. Tenant IDs from request bodies or query strings are never trusted as authority. Tenant-owned tables carry ownership keys and automated tests attempt cross-tenant access through HTTP, jobs, reports, files, and sync.
