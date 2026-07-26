# Platform Matrix

| Capability | Windows | Android | Web |
|---|---|---|---|
| Authority | Local SQLite installation | Laravel/MySQL | Laravel/MySQL |
| Authentication | Local account | Laravel/Sanctum | Laravel/Sanctum |
| Offline data | Full authoritative dataset | Cache, working set, outbox | Browser cache, working set, outbox |
| Network required | No | For cloud sync | For cloud sync |
| Backup/restore | Local execute: merge/replace | Request cloud operation only | Request cloud operation only |
| Cloud execution | Never | Super-Superadmin only | Super-Superadmin only |
| Printing | Windows spooler/raw adapter | Bluetooth, LAN/TCP, system/vendor adapters | PDF/browser print; bridge later |
| Local storage | Drift + native SQLite | Drift + native SQLite | Drift + SQLite WASM + browser persistence |
| API | None at runtime | `/api/v1` | `/api/v1` |

The Flutter target folders are not currently enabled because no Flutter project exists. Target creation belongs to the scaffold phase and must create Windows, Android, and Web in the same project.

Features shared across platforms include branding, shell, domain models, validation, permissions, company/users, parts, label design rules, reports, and printer job construction. Platform implementations are restricted to database opening, secure credential storage, file selection/export, connectivity, and printer transport.
