import 'bootstrap_store.dart';

BootstrapStore createBootstrapStore() => _UnsupportedBootstrapStore();

class _UnsupportedBootstrapStore implements BootstrapStore {
  @override
  Future<String?> readCompanyId() async => null;
  @override
  Future<void> writeCompanyId(String companyId) =>
      throw UnsupportedError('Windows bootstrap storage is unavailable.');
}
