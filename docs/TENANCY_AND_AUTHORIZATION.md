# Tenancy and Authorization

## Hierarchy

`Super-Superadmin -> Superadmin assignments -> Tenant -> optional Subtenant -> Tenant Admin -> User`.

Platform-owner users are outside tenant data planes. A person may have multiple memberships; an authenticated cloud session selects one active membership. Superadmins see only explicitly assigned tenants/subtenants. Tenant admins manage their company scope. Normal users receive explicit operational permissions.

## Enforcement

Every tenant-owned table carries `tenant_id`; subtenant-owned data additionally carries nullable `subtenant_id`. Foreign keys and unique constraints include the ownership scope where practical. Global scopes are convenience only: policies, query services, route binding, jobs, exports, reports, and storage paths must independently preserve scope. Queue payloads carry a trusted membership context and re-authorize before execution.

Tenant identity is derived from the authenticated session/token and server-side membership. Client-supplied tenant identifiers may select only among already-authorized memberships and must never become an authorization fact.

## Permission map

| Operation | Platform owner | Superadmin | Tenant admin | Normal user |
|---|---:|---:|---:|---:|
| Manage platform owners/superadmins | Yes | No | No | No |
| Manage assigned tenants | Yes | Yes, assigned only | No | No |
| Manage company users/roles | Yes | Scoped | Yes | With permission |
| Operate parts/templates/printing | Scoped support | Scoped | Yes | Explicit permission |
| Request cloud backup/restore | Execute/manage | View assigned | Yes, request only | Explicit request permission |
| Execute cloud backup/restore | Yes only | No | No | No |
| Billing/subscription administration | Yes | Assigned scope | View/pay as granted | No |

Permissions use stable names such as `parts.read`, `parts.write`, `print.execute`, `backup.request`, and `reports.export`. Deny by default. Break-glass actions require re-authentication, reason capture, immutable audit, and notification.

Windows mirrors roles and permissions locally but has no platform-owner cloud powers. Its first-owner bootstrap and credential recovery design must be finalized before authentication implementation.
