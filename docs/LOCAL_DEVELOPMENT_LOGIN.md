# Local development login

XAMPP provides MySQL for the `codevault` database. Laravel must also be running as the HTTP API; MySQL or Apache running by itself does not expose Laravel's `/api/v1` routes.

Start the API from PowerShell:

```powershell
cd C:\Users\satab\Downloads\git\CodeVault
.\scripts\start_local_api.ps1
```

Flutter debug defaults:

- Web on this computer: `http://127.0.0.1:8000/api/v1`
- Android emulator: `http://10.0.2.2:8000/api/v1`
- Physical Android device: run with `--dart-define=ANDROID_LAN_API_URL=http://YOUR-PC-LAN-IP:8000/api/v1`; Windows Firewall must permit the private-network connection.

## Development credentials

All seeded accounts initially use password `ChangeMe@12345` and must change it immediately after their first successful login.

| Scope | Username | Email |
|---|---|---|
| Platform owner | `platform.owner` | `owner@ahanova.example` |
| Demo superadmin | `demo.superadmin` | `superadmin@ahanova.example` |
| EMDET tenant admin | `emdet.admin` | `emdet.admin@example.test` |
| EMDET operator | `emdet.operator` | `emdet.operator@example.test` |
| Apex tenant admin | `apex.components.admin` | `apex.components.admin@example.test` |
| Apex operator | `apex.components.operator` | `apex.components.operator@example.test` |

The platform-owner and superadmin accounts are not tenant accounts. Tenant operational testing should use `emdet.admin` or `apex.components.admin`.

Seed credentials are local/development only. Once an account changes its password, `ChangeMe@12345` is no longer valid for that account. Do not reseed or reset the database merely to recover a changed password; use the password-reset or temporary-password workflow.
