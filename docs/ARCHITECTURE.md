# CodeVault Architecture

Status: Baseline proposal for Prompt 01 (2026-07-26)

CodeVault comprises exactly two codebases: one Laravel REST backend and one Flutter application targeting Windows, Android, and Web. This document records the target architecture; neither repository contained an application at discovery time.

## System context

```text
Windows Flutter ── Drift/native SQLite (installation authority)

Android Flutter ─┐
                 ├─ HTTPS/JSON ─ Laravel API ─ MySQL (cloud authority)
Web Flutter ─────┘                    │
                         queue, scheduler, storage, SMTP
```

Windows has no runtime dependency on Laravel, MySQL, or the internet. Android and Web use a local working copy and outbox but treat Laravel/MySQL as authoritative.

## Laravel boundaries

Laravel is a modular monolith. HTTP controllers validate/authorize and delegate; application services own use cases; domain policies and invariants are framework-light; repositories isolate persistence. Modules are Authentication, Tenancy, Users/Permissions, Companies, Devices/Sessions, Parts, Ports/Printers, Label Templates, Code Rules, Sync, Subscriptions, Payments/Invoices, SMTP, Support, Cloud Backup/Restore, Audit, Reports, and API Documentation.

Cross-module references use UUID identifiers and application contracts. No module queries another module's tables as an informal API. Events handle audit and non-transactional side effects; queues handle email, report generation, and backup jobs.

## Flutter boundaries

The single application uses feature-based clean architecture. `core` contains configuration, errors, routing, networking, database infrastructure, logging, and design tokens. `shared` contains genuinely reusable UI/domain primitives. Each `features/<feature>` contains presentation, application/domain, and data layers. `platform` contains implementations of shared interfaces only.

Riverpod supplies dependency injection and state; GoRouter supplies guarded navigation; Dio supplies cloud HTTP; Drift supplies all local persistence. Conditional imports isolate `dart:io` and browser APIs. Business rules do not depend on widgets or platform plugins.

## Runtime rules

- All public API traffic is versioned under `/api/v1` and uses TLS in non-local environments.
- Laravel derives tenant scope from the authenticated membership/session, never an arbitrary body/query tenant ID.
- Syncable records use UUIDv7-compatible IDs, integer versions, UTC timestamps, tombstones, and idempotency keys.
- Permission checks occur in both the client (visibility/UX) and server (authority). Client checks are never trusted by the server.
- Structured logs use correlation IDs and redact secrets and label payloads where configured.
- Environment-specific values are injected; secrets are never compiled into Flutter or committed.

## Proposed repository structure

```text
CodeVault/                 CodeVaultLaravel/
  lib/                       app/Modules/
    core/                    app/Shared/
    shared/                  routes/api.php
    features/                database/migrations/
    platform/                tests/Feature/
    main.dart                tests/Unit/
  test/                      docs/openapi.yaml
  integration_test/
  docs/                    
```

Detailed decisions are in `docs/adr`. Platform capabilities are in `PLATFORM_MATRIX.md`.
