import '../../../core/network/api_client.dart';
import '../domain/sync_models.dart';

class DioSyncGateway implements SyncRemoteGateway {
  DioSyncGateway(this.client);
  final ApiClient client;
  @override
  Future<int> generation(String tenantId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/sync/generation',
      queryParameters: {'tenant_id': tenantId},
    );
    return ((response.data!['data'] as Map<String, dynamic>)['generation']
            as num)
        .toInt();
  }

  @override
  Future<PushResult> push(
    String tenantId,
    List<PushMutation> mutations,
    int generation,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/sync/push',
      data: {
        'tenant_id': tenantId,
        'generation': generation,
        'mutations': mutations
            .map(
              (item) => {
                'id': item.id,
                'entity_type': item.entityType,
                'entity_id': item.entityId,
                'operation': item.operation,
                'payload': item.payload,
                'base_version': item.baseVersion,
                'idempotency_key': item.idempotencyKey,
              },
            )
            .toList(),
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return PushResult(
      acceptedIds: Set<String>.from(data['accepted_ids'] as List? ?? const []),
      conflicts: Map<String, Map<String, dynamic>>.from(
        data['conflicts'] as Map? ?? const {},
      ),
    );
  }

  @override
  Future<PullPage> pull(String tenantId, String? cursor) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/sync/pull',
      queryParameters: {
        'tenant_id': tenantId,
        ...cursor == null ? const <String, dynamic>{} : {'cursor': cursor},
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return PullPage(
      changes: [
        for (final raw in data['changes'] as List)
          PullChange(
            entityType: raw['entity_type'] as String,
            entityId: raw['entity_id'] as String,
            payload: Map<String, dynamic>.from(raw['payload'] as Map),
            version: (raw['version'] as num).toInt(),
            deleted: raw['deleted'] as bool? ?? false,
          ),
      ],
      nextCursor: data['next_cursor'] as String?,
      generation: (data['generation'] as num).toInt(),
    );
  }
}
