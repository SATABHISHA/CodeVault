import 'bootstrap_store_stub.dart'
    if (dart.library.io) 'bootstrap_store_native.dart'
    as implementation;

abstract interface class BootstrapStore {
  Future<String?> readCompanyId();
  Future<void> writeCompanyId(String companyId);
}

BootstrapStore createBootstrapStore() => implementation.createBootstrapStore();
