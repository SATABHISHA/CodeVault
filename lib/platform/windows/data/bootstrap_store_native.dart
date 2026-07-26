import 'dart:io';

import 'package:path/path.dart' as path;

import 'bootstrap_store.dart';

BootstrapStore createBootstrapStore() => _NativeBootstrapStore();

class _NativeBootstrapStore implements BootstrapStore {
  File get _file {
    final root = Platform.environment['LOCALAPPDATA'];
    if (root == null || root.isEmpty) {
      throw StateError('LOCALAPPDATA is unavailable.');
    }
    return File(path.join(root, 'Ahanova', 'CodeVault', 'active_company'));
  }

  @override
  Future<String?> readCompanyId() async {
    if (!await _file.exists()) return null;
    final value = (await _file.readAsString()).trim();
    return RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(value) ? value : null;
  }

  @override
  Future<void> writeCompanyId(String companyId) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(companyId)) {
      throw ArgumentError.value(companyId);
    }
    await _file.parent.create(recursive: true);
    await _file.writeAsString(companyId, flush: true);
  }
}
