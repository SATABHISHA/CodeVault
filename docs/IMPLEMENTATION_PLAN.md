# Implementation Plan

Status: Architecture gate complete; implementation is blocked on the decisions listed below and the next approved prompt.

## Discovery baseline

On 2026-07-26 both Git worktrees were clean and each repository contained only an initial `README.md`. The Flutter repository is not a Flutter application; Windows, Android, and Web targets are not enabled. The Laravel repository is not a Laravel application. There are no manifests, dependencies, source folders, database configuration/migrations, authentication, tests, or existing application files to overwrite.

Observed tools: PHP 8.2.12 and Composer 2.8.12. `mysql` was not on `PATH`. Flutter/Dart version was not established by the initial command and must be verified before scaffolding. “Latest stable/LTS” must be pinned deliberately at scaffold time and recorded in lockfiles/tooling docs.

## Delivery sequence

1. Resolve architecture questions; agree supported versions, nonfunctional targets, and service providers.
2. Scaffold Laravel in the existing Laravel repository and the single three-target Flutter project in the existing Flutter repository; preserve Git history and README content.
3. Establish CI, environment validation, formatting/static analysis, test harnesses, OpenAPI skeleton, logging/error conventions, and schema migration policy.
4. Implement cloud identity, tenancy, memberships, roles/permissions, audit, and development-only owner seeder; implement Windows local identity separately behind the shared auth contract.
5. Implement Drift schemas, database openers, cloud API client, outbox/pull sync protocol, idempotency, and tenant generation recovery.
6. Deliver company/users, parts, ports/printers, templates/code rules, and print history vertically with authorization and sync tests.
7. Deliver shared label rendering and platform printer adapters incrementally, validated against selected hardware.
8. Deliver support, cloud backup/restore request workflow, owner execution controls, and Windows encrypted local backup/restore.
9. Deliver subscriptions, GST/tax profiles, invoices, payments, reports, SMTP administration, and platform-owner operations.
10. Complete threat model, performance/accessibility/compatibility testing, deployment automation, restore drill, operational runbooks, signing, and production readiness review.

Each phase must finish code, formatting, static analysis, migrations where applicable, automated tests, build/run documentation, changed-file report, and risks before the next phase.

## Blocking questions

- Which exact Laravel, Flutter/Dart, PHP, MySQL, browser, Windows, and Android versions are supported?
- Which tenancy model applies to subtenants: strict data partition, delegated organizational unit, or both?
- What are the initial role/permission catalogue and approval rules for platform-owner operations?
- Which printer models/languages/DPI/media, Android transports, and vendor SDKs are acceptance targets?
- What label-template interchange format and barcode standards/validation rules are required?
- What are SLA, RPO/RTO, retention, data residency, audit retention, privacy, and compliance requirements?
- Which payment gateway, GST/invoice rules, currencies, storage, SMTP, hosting, CI/CD, and observability services are approved?
- How is the first Windows local owner provisioned and recovered, and must local data/backup archives be encrypted with user or organization keys?
- What conflict UX and offline limits are acceptable, especially after cloud restore generation changes?

No feature implementation or random UI should begin until the relevant answers and next numeric prompt are approved.
