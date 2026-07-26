# Flutter foundation

CodeVault uses one Flutter application for Android, Web, and Windows. Shared navigation, branding, themes, responsive layouts, and reusable widgets live under `lib/`. Platform folders contain only native runner integration.

## API environments

- Android emulator debug: `http://10.0.2.2:8000/api/v1`
- Physical Android debug: `--dart-define=ANDROID_LAN_API_URL=http://<LAN-IP>:8000/api/v1`
- Web debug: `http://127.0.0.1:8000/api/v1`
- Release Web/Android: `--dart-define=API_URL=https://example.com/api/v1`
- Windows: no cloud API URL; its workflow is offline and authoritative locally.

Release Web and Android builds throw during configuration if `API_URL` is absent, preventing accidental localhost use.

## API contract

Prompt 07 creates no new server endpoints. `ApiClient` is the shared Dio transport for the Laravel `/api/v1` OpenAPI contract. It adds bearer tokens from secure storage and requests JSON. Feature repositories introduced in later prompts will consume the documented Laravel endpoints; widgets do not call APIs directly.

## Platform guards

- Windows: local backup/restore and Windows printing only; managed backup/restore request controls are hidden.
- Android: managed Laravel backup/restore requests and wireless printing capabilities.
- Web: managed Laravel backup/restore requests and browser printing.

## Build examples

```powershell
flutter run -d windows
flutter run -d chrome
flutter run -d emulator-5554
flutter run -d <android-device> --dart-define=ANDROID_LAN_API_URL=http://192.168.1.10:8000/api/v1
flutter build web --release --dart-define=API_URL=https://api.example.com/api/v1
flutter build apk --release --dart-define=API_URL=https://api.example.com/api/v1
```
