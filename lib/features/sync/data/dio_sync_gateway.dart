import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../domain/sync_models.dart';

class DioSyncGateway implements SyncRemoteGateway {
  DioSyncGateway(this.client, {required this.deviceId});
  final ApiClient client;
  final String deviceId;
  @override
  Future<GenerationState> generation(String tenantId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/tenants/$tenantId/sync/generation',
      options: Options(headers: {'X-Device-UUID': deviceId}),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final alignment = data['alignment'] as Map<String, dynamic>?;
    return GenerationState(
      generation: (data['generation'] as num).toInt(),
      alignmentRequired: data['alignment_required'] as bool? ?? false,
      alignmentId: alignment?['id'] as String?,
    );
  }

  @override
  Future<PushResult> push(
    String tenantId,
    List<PushMutation> mutations,
    int generation,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/tenants/$tenantId/sync/push',
      options: Options(headers: {'X-Device-UUID': deviceId}),
      data: {
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
      '/tenants/$tenantId/sync/pull',
      queryParameters: {
        'generation': await _generationNumber(tenantId),
        ...cursor == null ? const <String, dynamic>{} : {'cursor': cursor},
      },
      options: Options(headers: {'X-Device-UUID': deviceId}),
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
      hasMore: data['has_more'] as bool? ?? false,
    );
  }

  Future<int> _generationNumber(String tenantId) async =>
      (await generation(tenantId)).generation;

  @override
  Future<void> acknowledgeAlignment(
    String tenantId,
    String alignmentId,
    int generation,
  ) async {
    await client.dio.post<void>(
      '/tenants/$tenantId/alignment/$alignmentId/acknowledge',
      data: {'safety_backup_confirmed': true, 'generation': generation},
      options: Options(
        headers: {'X-Device-UUID': deviceId, 'X-Tenant-Generation': generation},
      ),
    );
  }
}
