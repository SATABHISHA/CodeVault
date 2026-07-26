class PushMutation {
  const PushMutation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    this.baseVersion,
  });
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final int? baseVersion;
}

class PullChange {
  const PullChange({
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.version,
    required this.deleted,
  });
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final int version;
  final bool deleted;
}

class PullPage {
  const PullPage({
    required this.changes,
    required this.nextCursor,
    required this.generation,
  });
  final List<PullChange> changes;
  final String? nextCursor;
  final int generation;
}

class PushResult {
  const PushResult({required this.acceptedIds, this.conflicts = const {}});
  final Set<String> acceptedIds;
  final Map<String, Map<String, dynamic>> conflicts;
}

abstract interface class SyncRemoteGateway {
  Future<int> generation(String tenantId);
  Future<PushResult> push(
    String tenantId,
    List<PushMutation> mutations,
    int generation,
  );
  Future<PullPage> pull(String tenantId, String? cursor);
}
