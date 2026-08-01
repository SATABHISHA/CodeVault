import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'bootstrap_store.dart';

BootstrapStore createBootstrapStore() => _NativeBootstrapStore();

class _NativeBootstrapStore implements BootstrapStore {
  Future<File> _getFile() async {
    if (Platform.isWindows) {
      final root = Platform.environment['LOCALAPPDATA'];
      if (root == null || root.isEmpty) {
        throw StateError('LOCALAPPDATA is unavailable.');
      }
      return File(path.join(root, 'Ahanova', 'CodeVault', 'active_company'));
    }
    // Android (and other non-Windows native platforms)
    final dir = await getApplicationSupportDirectory();
    return File(path.join(dir.path, 'active_company'));
  }

  @override
  Future<String?> readCompanyId() async {
    final file = await _getFile();
    if (!await file.exists()) return null;
    final value = (await file.readAsString()).trim();
    return RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(value) ? value : null;
  }

  @override
  Future<void> writeCompanyId(String companyId) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(companyId)) {
      throw ArgumentError.value(companyId);
    }
    final file = await _getFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(companyId, flush: true);
  }
}
