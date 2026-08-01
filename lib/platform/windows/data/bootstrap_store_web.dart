import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'bootstrap_store.dart';

BootstrapStore createBootstrapStore() => _WebBootstrapStore();

class _WebBootstrapStore implements BootstrapStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'codevault_local_company_id';

  @override
  Future<String?> readCompanyId() async {
    final value = await _storage.read(key: _key);
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(value)) return null;
    return value;
  }

  @override
  Future<void> writeCompanyId(String companyId) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(companyId)) {
      throw ArgumentError.value(companyId, 'companyId', 'Invalid UUID');
    }
    await _storage.write(key: _key, value: companyId);
  }
}
