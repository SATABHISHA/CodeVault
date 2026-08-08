import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/code_type_visibility_store.dart';
import '../domain/code_type_visibility.dart';

final codeTypeVisibilityProvider =
    NotifierProvider<CodeTypeVisibilityController, Set<String>>(
      CodeTypeVisibilityController.new,
    );

class CodeTypeVisibilityController extends Notifier<Set<String>> {
  final _store = const CodeTypeVisibilityStore();
  String? _loadedIdentity;

  @override
  Set<String> build() => Set.of(CodeTypeVisibility.all);

  Future<void> ensureLoaded({
    required String tenantId,
    required String userId,
  }) async {
    final identity = '$tenantId:$userId';
    if (_loadedIdentity == identity) return;
    _loadedIdentity = identity;
    try {
      state = await _store.load(tenantId: tenantId, userId: userId);
    } catch (_) {
      state = Set.of(CodeTypeVisibility.all);
    }
  }

  Future<bool> setVisible({
    required String tenantId,
    required String userId,
    required String type,
    required bool visible,
  }) async {
    final next = Set<String>.of(state);
    visible ? next.add(type) : next.remove(type);
    if (next.isEmpty) return false;
    final previous = state;
    state = CodeTypeVisibility.sanitize(next);
    try {
      await _store.save(
        tenantId: tenantId,
        userId: userId,
        visibleTypes: state,
      );
    } catch (_) {
      state = previous;
      rethrow;
    }
    return true;
  }
}
