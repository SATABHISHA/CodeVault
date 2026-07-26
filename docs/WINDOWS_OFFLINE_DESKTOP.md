# Windows offline desktop

Prompt 08 implements Windows as a local, authoritative application. It does not use Dio, Laravel, MySQL, synchronization, cloud alignment, cloud backup, or cloud restore.

## Storage

Each company uses a UUID-only directory:

```text
%LOCALAPPDATA%\Ahanova\CodeVault\companies\{company_uuid}\codevault.sqlite
```

SQLite enables foreign keys, WAL journaling, and full synchronous writes. Drift schema version 1 contains companies, local users, roles, settings, parts, ports, printers, label templates, serial/code rules, print jobs, audit logs, recovery challenges, and backup/import reports. Schema changes must increment `schemaVersion` and add an explicit migration before release.

The active company UUID is stored in `%LOCALAPPDATA%\Ahanova\CodeVault\active_company`. It is validated before being used as a directory segment.

## Local service APIs

These are in-process Dart APIs, not HTTP endpoints:

- `LocalAccountService.initializeCompany`: creates the first company and local administrator transactionally.
- `LocalAccountService.login`: verifies a PBKDF2-HMAC-SHA256 digest, enforces active state and lockout, and writes an audit event.
- `LocalAccountService.createUser`: creates a local user with a cryptographically generated temporary password and mandatory password change.
- `LocalAccountService.setActive`: activates or deactivates a local user and audits the actor.
- `LocalAccountService.editUser`: changes display details and field-level permission assignments and audits the actor.
- `LocalAccountService.resetPassword`: generates a cryptographically secure temporary password, clears lockout, and mandates a password change.
- `LocalAccountService.changePassword`: verifies the current password, applies a new digest, clears the mandatory-change flag, and audits the event.
- `OfflineRecoveryService.create`: requires explicit confirmation and creates an audited six-digit challenge with a five-minute expiry.
- `OfflineRecoveryService.consume`: permits five attempts, consumes a challenge once, clears lockout, and forces a password change. There is no universal recovery code.
- `LocalBackupService.create`: produces a `.cvbackup` ZIP container with SQLite, optional assets, a versioned manifest, and SHA-256 integrity value.
- `LocalBackupService.verify`: validates archive structure, format version, ZIP integrity, and database checksum before restore.
- `LocalBackupService.merge`: imports missing operational records by stable UUID inside a transaction and returns inserted counts as a conflict report.
- `LocalBackupService.replace`: creates an automatic pre-replace backup, stages replacement bytes, and rolls back from the safety copy on failure. The database must be closed before replacement.
- `WindowsPrinterAdapter.testConnection` and `print`: shared Windows printing boundary. `MockPrinterAdapter` provides deterministic tests without hardware.

No network API is created or called by the Windows implementation.

## Authentication and permissions

Passwords use PBKDF2-HMAC-SHA256 with 210,000 iterations, a random 32-byte salt, and constant-time comparison. Five consecutive failures lock an account for 15 minutes. The first administrator and temporary-password users must change their password. Administrative capabilities are explicit permission strings; UI modules must be guarded as they are connected to later feature screens.

## Backup and restore operations

Only an authenticated local administrator with `backup.manage` may expose backup actions. Merge never overwrites matching UUIDs. Replace requires explicit confirmation, a closed database connection, successful archive verification, and a pre-replace safety copy. Production UI integration should use a native file picker and persist the generated `BackupReports` record.

`.cvbackup` protects integrity, not confidentiality. Backup encryption/key custody remains a release-blocking product decision; sensitive production exports should be stored on encrypted media until an approved encrypted-container format is added.

## Printing adapters

The domain supports ZPL, TSPL, EPL, CPCL, GoDEX, and raster language declarations. Prompt 08 supplies the testable adapter boundary and mock printer. Installed-printer spooler, raw TCP/IP, and COM transports require representative printer hardware and are intentionally isolated behind this interface. A physical print job cannot generally guarantee exactly-once delivery.

## Build and packaging

```powershell
flutter test
flutter analyze
flutter build windows --release
```

The release output is under `build\windows\x64\runner\Release`. The Inno Setup definition in `windows\installer\codevault.iss` creates Start Menu/Desktop shortcuts, an uninstaller, and leaves `%LOCALAPPDATA%\Ahanova\CodeVault` untouched during uninstall so company data is not silently destroyed.
