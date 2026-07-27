// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_cache_database.dart';

// ignore_for_file: type=lint
class $CachedPartsTable extends CachedParts
    with TableInfo<$CachedPartsTable, CachedPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDeviceMeta = const VerificationMeta(
    'sourceDevice',
  );
  @override
  late final GeneratedColumn<String> sourceDevice = GeneratedColumn<String>(
    'source_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverGenerationMeta = const VerificationMeta(
    'serverGeneration',
  );
  @override
  late final GeneratedColumn<int> serverGeneration = GeneratedColumn<int>(
    'server_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    payloadJson,
    serverVersion,
    deleted,
    updatedAt,
    syncStatus,
    lastSyncedAt,
    sourceDevice,
    serverGeneration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverVersionMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_device')) {
      context.handle(
        _sourceDeviceMeta,
        sourceDevice.isAcceptableOrUnknown(
          data['source_device']!,
          _sourceDeviceMeta,
        ),
      );
    }
    if (data.containsKey('server_generation')) {
      context.handle(
        _serverGenerationMeta,
        serverGeneration.isAcceptableOrUnknown(
          data['server_generation']!,
          _serverGenerationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, id};
  @override
  CachedPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      sourceDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device'],
      ),
      serverGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_generation'],
      )!,
    );
  }

  @override
  $CachedPartsTable createAlias(String alias) {
    return $CachedPartsTable(attachedDatabase, alias);
  }
}

class CachedPart extends DataClass implements Insertable<CachedPart> {
  final String id;
  final String tenantId;
  final String payloadJson;
  final int serverVersion;
  final bool deleted;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final String? sourceDevice;
  final int serverGeneration;
  const CachedPart({
    required this.id,
    required this.tenantId,
    required this.payloadJson,
    required this.serverVersion,
    required this.deleted,
    required this.updatedAt,
    required this.syncStatus,
    this.lastSyncedAt,
    this.sourceDevice,
    required this.serverGeneration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['server_version'] = Variable<int>(serverVersion);
    map['deleted'] = Variable<bool>(deleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || sourceDevice != null) {
      map['source_device'] = Variable<String>(sourceDevice);
    }
    map['server_generation'] = Variable<int>(serverGeneration);
    return map;
  }

  CachedPartsCompanion toCompanion(bool nullToAbsent) {
    return CachedPartsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      payloadJson: Value(payloadJson),
      serverVersion: Value(serverVersion),
      deleted: Value(deleted),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      sourceDevice: sourceDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDevice),
      serverGeneration: Value(serverGeneration),
    );
  }

  factory CachedPart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPart(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      sourceDevice: serializer.fromJson<String?>(json['sourceDevice']),
      serverGeneration: serializer.fromJson<int>(json['serverGeneration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'deleted': serializer.toJson<bool>(deleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'sourceDevice': serializer.toJson<String?>(sourceDevice),
      'serverGeneration': serializer.toJson<int>(serverGeneration),
    };
  }

  CachedPart copyWith({
    String? id,
    String? tenantId,
    String? payloadJson,
    int? serverVersion,
    bool? deleted,
    DateTime? updatedAt,
    String? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> sourceDevice = const Value.absent(),
    int? serverGeneration,
  }) => CachedPart(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    payloadJson: payloadJson ?? this.payloadJson,
    serverVersion: serverVersion ?? this.serverVersion,
    deleted: deleted ?? this.deleted,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    sourceDevice: sourceDevice.present ? sourceDevice.value : this.sourceDevice,
    serverGeneration: serverGeneration ?? this.serverGeneration,
  );
  CachedPart copyWithCompanion(CachedPartsCompanion data) {
    return CachedPart(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      sourceDevice: data.sourceDevice.present
          ? data.sourceDevice.value
          : this.sourceDevice,
      serverGeneration: data.serverGeneration.present
          ? data.serverGeneration.value
          : this.serverGeneration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPart(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('serverGeneration: $serverGeneration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    payloadJson,
    serverVersion,
    deleted,
    updatedAt,
    syncStatus,
    lastSyncedAt,
    sourceDevice,
    serverGeneration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPart &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.payloadJson == this.payloadJson &&
          other.serverVersion == this.serverVersion &&
          other.deleted == this.deleted &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.sourceDevice == this.sourceDevice &&
          other.serverGeneration == this.serverGeneration);
}

class CachedPartsCompanion extends UpdateCompanion<CachedPart> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> payloadJson;
  final Value<int> serverVersion;
  final Value<bool> deleted;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> sourceDevice;
  final Value<int> serverGeneration;
  final Value<int> rowid;
  const CachedPartsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.serverGeneration = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPartsCompanion.insert({
    required String id,
    required String tenantId,
    required String payloadJson,
    required int serverVersion,
    this.deleted = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.serverGeneration = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       payloadJson = Value(payloadJson),
       serverVersion = Value(serverVersion),
       updatedAt = Value(updatedAt);
  static Insertable<CachedPart> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? payloadJson,
    Expression<int>? serverVersion,
    Expression<bool>? deleted,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? sourceDevice,
    Expression<int>? serverGeneration,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (serverVersion != null) 'server_version': serverVersion,
      if (deleted != null) 'deleted': deleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (sourceDevice != null) 'source_device': sourceDevice,
      if (serverGeneration != null) 'server_generation': serverGeneration,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPartsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? payloadJson,
    Value<int>? serverVersion,
    Value<bool>? deleted,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? sourceDevice,
    Value<int>? serverGeneration,
    Value<int>? rowid,
  }) {
    return CachedPartsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      payloadJson: payloadJson ?? this.payloadJson,
      serverVersion: serverVersion ?? this.serverVersion,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      serverGeneration: serverGeneration ?? this.serverGeneration,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (sourceDevice.present) {
      map['source_device'] = Variable<String>(sourceDevice.value);
    }
    if (serverGeneration.present) {
      map['server_generation'] = Variable<int>(serverGeneration.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPartsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('serverGeneration: $serverGeneration, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    entityType,
    entityId,
    operation,
    payloadJson,
    baseVersion,
    idempotencyKey,
    attempts,
    nextAttemptAt,
    lastError,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String tenantId;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final int? baseVersion;
  final String idempotencyKey;
  final int attempts;
  final DateTime nextAttemptAt;
  final String? lastError;
  final String syncStatus;
  final DateTime createdAt;
  const SyncOutboxData({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    this.baseVersion,
    required this.idempotencyKey,
    required this.attempts,
    required this.nextAttemptAt,
    this.lastError,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      idempotencyKey: Value(idempotencyKey),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? tenantId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    Value<int?> baseVersion = const Value.absent(),
    String? idempotencyKey,
    int? attempts,
    DateTime? nextAttemptAt,
    Value<String?> lastError = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
  }) => SyncOutboxData(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    entityType,
    entityId,
    operation,
    payloadJson,
    baseVersion,
    idempotencyKey,
    attempts,
    nextAttemptAt,
    lastError,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.baseVersion == this.baseVersion &&
          other.idempotencyKey == this.idempotencyKey &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int?> baseVersion;
  final Value<String> idempotencyKey;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<String?> lastError;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String tenantId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    this.baseVersion = const Value.absent(),
    required String idempotencyKey,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? baseVersion,
    Expression<String>? idempotencyKey,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (baseVersion != null) 'base_version': baseVersion,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int?>? baseVersion,
    Value<String>? idempotencyKey,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<String?>? lastError,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      baseVersion: baseVersion ?? this.baseVersion,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadJsonMeta = const VerificationMeta(
    'localPayloadJson',
  );
  @override
  late final GeneratedColumn<String> localPayloadJson = GeneratedColumn<String>(
    'local_payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverPayloadJsonMeta = const VerificationMeta(
    'serverPayloadJson',
  );
  @override
  late final GeneratedColumn<String> serverPayloadJson =
      GeneratedColumn<String>(
        'server_payload_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    entityType,
    entityId,
    localPayloadJson,
    serverPayloadJson,
    reason,
    detectedAt,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_payload_json')) {
      context.handle(
        _localPayloadJsonMeta,
        localPayloadJson.isAcceptableOrUnknown(
          data['local_payload_json']!,
          _localPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadJsonMeta);
    }
    if (data.containsKey('server_payload_json')) {
      context.handle(
        _serverPayloadJsonMeta,
        serverPayloadJson.isAcceptableOrUnknown(
          data['server_payload_json']!,
          _serverPayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverPayloadJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload_json'],
      )!,
      serverPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_payload_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String tenantId;
  final String entityType;
  final String entityId;
  final String localPayloadJson;
  final String serverPayloadJson;
  final String reason;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  const SyncConflict({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.entityId,
    required this.localPayloadJson,
    required this.serverPayloadJson,
    required this.reason,
    required this.detectedAt,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_payload_json'] = Variable<String>(localPayloadJson);
    map['server_payload_json'] = Variable<String>(serverPayloadJson);
    map['reason'] = Variable<String>(reason);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localPayloadJson: Value(localPayloadJson),
      serverPayloadJson: Value(serverPayloadJson),
      reason: Value(reason),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localPayloadJson: serializer.fromJson<String>(json['localPayloadJson']),
      serverPayloadJson: serializer.fromJson<String>(json['serverPayloadJson']),
      reason: serializer.fromJson<String>(json['reason']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localPayloadJson': serializer.toJson<String>(localPayloadJson),
      'serverPayloadJson': serializer.toJson<String>(serverPayloadJson),
      'reason': serializer.toJson<String>(reason),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? tenantId,
    String? entityType,
    String? entityId,
    String? localPayloadJson,
    String? serverPayloadJson,
    String? reason,
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localPayloadJson: localPayloadJson ?? this.localPayloadJson,
    serverPayloadJson: serverPayloadJson ?? this.serverPayloadJson,
    reason: reason ?? this.reason,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localPayloadJson: data.localPayloadJson.present
          ? data.localPayloadJson.value
          : this.localPayloadJson,
      serverPayloadJson: data.serverPayloadJson.present
          ? data.serverPayloadJson.value
          : this.serverPayloadJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('serverPayloadJson: $serverPayloadJson, ')
          ..write('reason: $reason, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    entityType,
    entityId,
    localPayloadJson,
    serverPayloadJson,
    reason,
    detectedAt,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localPayloadJson == this.localPayloadJson &&
          other.serverPayloadJson == this.serverPayloadJson &&
          other.reason == this.reason &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localPayloadJson;
  final Value<String> serverPayloadJson;
  final Value<String> reason;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolution;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localPayloadJson = const Value.absent(),
    this.serverPayloadJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String tenantId,
    required String entityType,
    required String entityId,
    required String localPayloadJson,
    required String serverPayloadJson,
    required String reason,
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localPayloadJson = Value(localPayloadJson),
       serverPayloadJson = Value(serverPayloadJson),
       reason = Value(reason);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localPayloadJson,
    Expression<String>? serverPayloadJson,
    Expression<String>? reason,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localPayloadJson != null) 'local_payload_json': localPayloadJson,
      if (serverPayloadJson != null) 'server_payload_json': serverPayloadJson,
      if (reason != null) 'reason': reason,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localPayloadJson,
    Value<String>? serverPayloadJson,
    Value<String>? reason,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localPayloadJson: localPayloadJson ?? this.localPayloadJson,
      serverPayloadJson: serverPayloadJson ?? this.serverPayloadJson,
      reason: reason ?? this.reason,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localPayloadJson.present) {
      map['local_payload_json'] = Variable<String>(localPayloadJson.value);
    }
    if (serverPayloadJson.present) {
      map['server_payload_json'] = Variable<String>(serverPayloadJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('serverPayloadJson: $serverPayloadJson, ')
          ..write('reason: $reason, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pullCursorMeta = const VerificationMeta(
    'pullCursor',
  );
  @override
  late final GeneratedColumn<String> pullCursor = GeneratedColumn<String>(
    'pull_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generationMeta = const VerificationMeta(
    'generation',
  );
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
    'generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alignmentStatusMeta = const VerificationMeta(
    'alignmentStatus',
  );
  @override
  late final GeneratedColumn<String> alignmentStatus = GeneratedColumn<String>(
    'alignment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('aligned'),
  );
  static const VerificationMeta _lastAlignmentReportMeta =
      const VerificationMeta('lastAlignmentReport');
  @override
  late final GeneratedColumn<String> lastAlignmentReport =
      GeneratedColumn<String>(
        'last_alignment_report',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    tenantId,
    pullCursor,
    generation,
    lastPulledAt,
    alignmentStatus,
    lastAlignmentReport,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('pull_cursor')) {
      context.handle(
        _pullCursorMeta,
        pullCursor.isAcceptableOrUnknown(data['pull_cursor']!, _pullCursorMeta),
      );
    }
    if (data.containsKey('generation')) {
      context.handle(
        _generationMeta,
        generation.isAcceptableOrUnknown(data['generation']!, _generationMeta),
      );
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    }
    if (data.containsKey('alignment_status')) {
      context.handle(
        _alignmentStatusMeta,
        alignmentStatus.isAcceptableOrUnknown(
          data['alignment_status']!,
          _alignmentStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_alignment_report')) {
      context.handle(
        _lastAlignmentReportMeta,
        lastAlignmentReport.isAcceptableOrUnknown(
          data['last_alignment_report']!,
          _lastAlignmentReportMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      pullCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pull_cursor'],
      ),
      generation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      ),
      alignmentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alignment_status'],
      )!,
      lastAlignmentReport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_alignment_report'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String tenantId;
  final String? pullCursor;
  final int generation;
  final DateTime? lastPulledAt;
  final String alignmentStatus;
  final String? lastAlignmentReport;
  const SyncMetadataData({
    required this.tenantId,
    this.pullCursor,
    required this.generation,
    this.lastPulledAt,
    required this.alignmentStatus,
    this.lastAlignmentReport,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    if (!nullToAbsent || pullCursor != null) {
      map['pull_cursor'] = Variable<String>(pullCursor);
    }
    map['generation'] = Variable<int>(generation);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    }
    map['alignment_status'] = Variable<String>(alignmentStatus);
    if (!nullToAbsent || lastAlignmentReport != null) {
      map['last_alignment_report'] = Variable<String>(lastAlignmentReport);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      tenantId: Value(tenantId),
      pullCursor: pullCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(pullCursor),
      generation: Value(generation),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      alignmentStatus: Value(alignmentStatus),
      lastAlignmentReport: lastAlignmentReport == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAlignmentReport),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      tenantId: serializer.fromJson<String>(json['tenantId']),
      pullCursor: serializer.fromJson<String?>(json['pullCursor']),
      generation: serializer.fromJson<int>(json['generation']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
      alignmentStatus: serializer.fromJson<String>(json['alignmentStatus']),
      lastAlignmentReport: serializer.fromJson<String?>(
        json['lastAlignmentReport'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'pullCursor': serializer.toJson<String?>(pullCursor),
      'generation': serializer.toJson<int>(generation),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
      'alignmentStatus': serializer.toJson<String>(alignmentStatus),
      'lastAlignmentReport': serializer.toJson<String?>(lastAlignmentReport),
    };
  }

  SyncMetadataData copyWith({
    String? tenantId,
    Value<String?> pullCursor = const Value.absent(),
    int? generation,
    Value<DateTime?> lastPulledAt = const Value.absent(),
    String? alignmentStatus,
    Value<String?> lastAlignmentReport = const Value.absent(),
  }) => SyncMetadataData(
    tenantId: tenantId ?? this.tenantId,
    pullCursor: pullCursor.present ? pullCursor.value : this.pullCursor,
    generation: generation ?? this.generation,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    alignmentStatus: alignmentStatus ?? this.alignmentStatus,
    lastAlignmentReport: lastAlignmentReport.present
        ? lastAlignmentReport.value
        : this.lastAlignmentReport,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      pullCursor: data.pullCursor.present
          ? data.pullCursor.value
          : this.pullCursor,
      generation: data.generation.present
          ? data.generation.value
          : this.generation,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      alignmentStatus: data.alignmentStatus.present
          ? data.alignmentStatus.value
          : this.alignmentStatus,
      lastAlignmentReport: data.lastAlignmentReport.present
          ? data.lastAlignmentReport.value
          : this.lastAlignmentReport,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('tenantId: $tenantId, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('generation: $generation, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('alignmentStatus: $alignmentStatus, ')
          ..write('lastAlignmentReport: $lastAlignmentReport')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tenantId,
    pullCursor,
    generation,
    lastPulledAt,
    alignmentStatus,
    lastAlignmentReport,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.tenantId == this.tenantId &&
          other.pullCursor == this.pullCursor &&
          other.generation == this.generation &&
          other.lastPulledAt == this.lastPulledAt &&
          other.alignmentStatus == this.alignmentStatus &&
          other.lastAlignmentReport == this.lastAlignmentReport);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> tenantId;
  final Value<String?> pullCursor;
  final Value<int> generation;
  final Value<DateTime?> lastPulledAt;
  final Value<String> alignmentStatus;
  final Value<String?> lastAlignmentReport;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.tenantId = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.generation = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.alignmentStatus = const Value.absent(),
    this.lastAlignmentReport = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String tenantId,
    this.pullCursor = const Value.absent(),
    this.generation = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.alignmentStatus = const Value.absent(),
    this.lastAlignmentReport = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tenantId = Value(tenantId);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? tenantId,
    Expression<String>? pullCursor,
    Expression<int>? generation,
    Expression<DateTime>? lastPulledAt,
    Expression<String>? alignmentStatus,
    Expression<String>? lastAlignmentReport,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (pullCursor != null) 'pull_cursor': pullCursor,
      if (generation != null) 'generation': generation,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (alignmentStatus != null) 'alignment_status': alignmentStatus,
      if (lastAlignmentReport != null)
        'last_alignment_report': lastAlignmentReport,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? tenantId,
    Value<String?>? pullCursor,
    Value<int>? generation,
    Value<DateTime?>? lastPulledAt,
    Value<String>? alignmentStatus,
    Value<String?>? lastAlignmentReport,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      tenantId: tenantId ?? this.tenantId,
      pullCursor: pullCursor ?? this.pullCursor,
      generation: generation ?? this.generation,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      alignmentStatus: alignmentStatus ?? this.alignmentStatus,
      lastAlignmentReport: lastAlignmentReport ?? this.lastAlignmentReport,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (pullCursor.present) {
      map['pull_cursor'] = Variable<String>(pullCursor.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (alignmentStatus.present) {
      map['alignment_status'] = Variable<String>(alignmentStatus.value);
    }
    if (lastAlignmentReport.present) {
      map['last_alignment_report'] = Variable<String>(
        lastAlignmentReport.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('generation: $generation, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('alignmentStatus: $alignmentStatus, ')
          ..write('lastAlignmentReport: $lastAlignmentReport, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AndroidPrintJobsTable extends AndroidPrintJobs
    with TableInfo<$AndroidPrintJobsTable, AndroidPrintJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AndroidPrintJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printerIdMeta = const VerificationMeta(
    'printerId',
  );
  @override
  late final GeneratedColumn<String> printerId = GeneratedColumn<String>(
    'printer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultUncertainMeta = const VerificationMeta(
    'resultUncertain',
  );
  @override
  late final GeneratedColumn<bool> resultUncertain = GeneratedColumn<bool>(
    'result_uncertain',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("result_uncertain" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    printerId,
    payload,
    quantity,
    state,
    resultUncertain,
    attempts,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'android_print_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AndroidPrintJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('printer_id')) {
      context.handle(
        _printerIdMeta,
        printerId.isAcceptableOrUnknown(data['printer_id']!, _printerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_printerIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('result_uncertain')) {
      context.handle(
        _resultUncertainMeta,
        resultUncertain.isAcceptableOrUnknown(
          data['result_uncertain']!,
          _resultUncertainMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AndroidPrintJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AndroidPrintJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      printerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      resultUncertain: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}result_uncertain'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AndroidPrintJobsTable createAlias(String alias) {
    return $AndroidPrintJobsTable(attachedDatabase, alias);
  }
}

class AndroidPrintJob extends DataClass implements Insertable<AndroidPrintJob> {
  final String id;
  final String tenantId;
  final String printerId;
  final String payload;
  final int quantity;
  final String state;
  final bool resultUncertain;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  const AndroidPrintJob({
    required this.id,
    required this.tenantId,
    required this.printerId,
    required this.payload,
    required this.quantity,
    required this.state,
    required this.resultUncertain,
    required this.attempts,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['printer_id'] = Variable<String>(printerId);
    map['payload'] = Variable<String>(payload);
    map['quantity'] = Variable<int>(quantity);
    map['state'] = Variable<String>(state);
    map['result_uncertain'] = Variable<bool>(resultUncertain);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AndroidPrintJobsCompanion toCompanion(bool nullToAbsent) {
    return AndroidPrintJobsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      printerId: Value(printerId),
      payload: Value(payload),
      quantity: Value(quantity),
      state: Value(state),
      resultUncertain: Value(resultUncertain),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory AndroidPrintJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AndroidPrintJob(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      printerId: serializer.fromJson<String>(json['printerId']),
      payload: serializer.fromJson<String>(json['payload']),
      quantity: serializer.fromJson<int>(json['quantity']),
      state: serializer.fromJson<String>(json['state']),
      resultUncertain: serializer.fromJson<bool>(json['resultUncertain']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'printerId': serializer.toJson<String>(printerId),
      'payload': serializer.toJson<String>(payload),
      'quantity': serializer.toJson<int>(quantity),
      'state': serializer.toJson<String>(state),
      'resultUncertain': serializer.toJson<bool>(resultUncertain),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AndroidPrintJob copyWith({
    String? id,
    String? tenantId,
    String? printerId,
    String? payload,
    int? quantity,
    String? state,
    bool? resultUncertain,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
  }) => AndroidPrintJob(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    printerId: printerId ?? this.printerId,
    payload: payload ?? this.payload,
    quantity: quantity ?? this.quantity,
    state: state ?? this.state,
    resultUncertain: resultUncertain ?? this.resultUncertain,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  AndroidPrintJob copyWithCompanion(AndroidPrintJobsCompanion data) {
    return AndroidPrintJob(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      printerId: data.printerId.present ? data.printerId.value : this.printerId,
      payload: data.payload.present ? data.payload.value : this.payload,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      state: data.state.present ? data.state.value : this.state,
      resultUncertain: data.resultUncertain.present
          ? data.resultUncertain.value
          : this.resultUncertain,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AndroidPrintJob(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('printerId: $printerId, ')
          ..write('payload: $payload, ')
          ..write('quantity: $quantity, ')
          ..write('state: $state, ')
          ..write('resultUncertain: $resultUncertain, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    printerId,
    payload,
    quantity,
    state,
    resultUncertain,
    attempts,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AndroidPrintJob &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.printerId == this.printerId &&
          other.payload == this.payload &&
          other.quantity == this.quantity &&
          other.state == this.state &&
          other.resultUncertain == this.resultUncertain &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class AndroidPrintJobsCompanion extends UpdateCompanion<AndroidPrintJob> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> printerId;
  final Value<String> payload;
  final Value<int> quantity;
  final Value<String> state;
  final Value<bool> resultUncertain;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AndroidPrintJobsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.printerId = const Value.absent(),
    this.payload = const Value.absent(),
    this.quantity = const Value.absent(),
    this.state = const Value.absent(),
    this.resultUncertain = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AndroidPrintJobsCompanion.insert({
    required String id,
    required String tenantId,
    required String printerId,
    required String payload,
    required int quantity,
    required String state,
    this.resultUncertain = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       printerId = Value(printerId),
       payload = Value(payload),
       quantity = Value(quantity),
       state = Value(state);
  static Insertable<AndroidPrintJob> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? printerId,
    Expression<String>? payload,
    Expression<int>? quantity,
    Expression<String>? state,
    Expression<bool>? resultUncertain,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (printerId != null) 'printer_id': printerId,
      if (payload != null) 'payload': payload,
      if (quantity != null) 'quantity': quantity,
      if (state != null) 'state': state,
      if (resultUncertain != null) 'result_uncertain': resultUncertain,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AndroidPrintJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? printerId,
    Value<String>? payload,
    Value<int>? quantity,
    Value<String>? state,
    Value<bool>? resultUncertain,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AndroidPrintJobsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      printerId: printerId ?? this.printerId,
      payload: payload ?? this.payload,
      quantity: quantity ?? this.quantity,
      state: state ?? this.state,
      resultUncertain: resultUncertain ?? this.resultUncertain,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (printerId.present) {
      map['printer_id'] = Variable<String>(printerId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (resultUncertain.present) {
      map['result_uncertain'] = Variable<bool>(resultUncertain.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AndroidPrintJobsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('printerId: $printerId, ')
          ..write('payload: $payload, ')
          ..write('quantity: $quantity, ')
          ..write('state: $state, ')
          ..write('resultUncertain: $resultUncertain, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AndroidPrinterProfilesTable extends AndroidPrinterProfiles
    with TableInfo<$AndroidPrinterProfilesTable, AndroidPrinterProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AndroidPrinterProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transportMeta = const VerificationMeta(
    'transport',
  );
  @override
  late final GeneratedColumn<String> transport = GeneratedColumn<String>(
    'transport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portIdMeta = const VerificationMeta('portId');
  @override
  late final GeneratedColumn<String> portId = GeneratedColumn<String>(
    'port_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    name,
    transport,
    language,
    address,
    portId,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'android_printer_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AndroidPrinterProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('transport')) {
      context.handle(
        _transportMeta,
        transport.isAcceptableOrUnknown(data['transport']!, _transportMeta),
      );
    } else if (isInserting) {
      context.missing(_transportMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('port_id')) {
      context.handle(
        _portIdMeta,
        portId.isAcceptableOrUnknown(data['port_id']!, _portIdMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, id};
  @override
  AndroidPrinterProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AndroidPrinterProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      transport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transport'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      portId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}port_id'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $AndroidPrinterProfilesTable createAlias(String alias) {
    return $AndroidPrinterProfilesTable(attachedDatabase, alias);
  }
}

class AndroidPrinterProfile extends DataClass
    implements Insertable<AndroidPrinterProfile> {
  final String id;
  final String tenantId;
  final String name;
  final String transport;
  final String language;
  final String address;
  final String? portId;
  final bool isDefault;
  const AndroidPrinterProfile({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.transport,
    required this.language,
    required this.address,
    this.portId,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['name'] = Variable<String>(name);
    map['transport'] = Variable<String>(transport);
    map['language'] = Variable<String>(language);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || portId != null) {
      map['port_id'] = Variable<String>(portId);
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  AndroidPrinterProfilesCompanion toCompanion(bool nullToAbsent) {
    return AndroidPrinterProfilesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      name: Value(name),
      transport: Value(transport),
      language: Value(language),
      address: Value(address),
      portId: portId == null && nullToAbsent
          ? const Value.absent()
          : Value(portId),
      isDefault: Value(isDefault),
    );
  }

  factory AndroidPrinterProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AndroidPrinterProfile(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      name: serializer.fromJson<String>(json['name']),
      transport: serializer.fromJson<String>(json['transport']),
      language: serializer.fromJson<String>(json['language']),
      address: serializer.fromJson<String>(json['address']),
      portId: serializer.fromJson<String?>(json['portId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'name': serializer.toJson<String>(name),
      'transport': serializer.toJson<String>(transport),
      'language': serializer.toJson<String>(language),
      'address': serializer.toJson<String>(address),
      'portId': serializer.toJson<String?>(portId),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  AndroidPrinterProfile copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? transport,
    String? language,
    String? address,
    Value<String?> portId = const Value.absent(),
    bool? isDefault,
  }) => AndroidPrinterProfile(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    name: name ?? this.name,
    transport: transport ?? this.transport,
    language: language ?? this.language,
    address: address ?? this.address,
    portId: portId.present ? portId.value : this.portId,
    isDefault: isDefault ?? this.isDefault,
  );
  AndroidPrinterProfile copyWithCompanion(
    AndroidPrinterProfilesCompanion data,
  ) {
    return AndroidPrinterProfile(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      name: data.name.present ? data.name.value : this.name,
      transport: data.transport.present ? data.transport.value : this.transport,
      language: data.language.present ? data.language.value : this.language,
      address: data.address.present ? data.address.value : this.address,
      portId: data.portId.present ? data.portId.value : this.portId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AndroidPrinterProfile(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('transport: $transport, ')
          ..write('language: $language, ')
          ..write('address: $address, ')
          ..write('portId: $portId, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    name,
    transport,
    language,
    address,
    portId,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AndroidPrinterProfile &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.name == this.name &&
          other.transport == this.transport &&
          other.language == this.language &&
          other.address == this.address &&
          other.portId == this.portId &&
          other.isDefault == this.isDefault);
}

class AndroidPrinterProfilesCompanion
    extends UpdateCompanion<AndroidPrinterProfile> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> name;
  final Value<String> transport;
  final Value<String> language;
  final Value<String> address;
  final Value<String?> portId;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const AndroidPrinterProfilesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.name = const Value.absent(),
    this.transport = const Value.absent(),
    this.language = const Value.absent(),
    this.address = const Value.absent(),
    this.portId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AndroidPrinterProfilesCompanion.insert({
    required String id,
    required String tenantId,
    required String name,
    required String transport,
    required String language,
    required String address,
    this.portId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       name = Value(name),
       transport = Value(transport),
       language = Value(language),
       address = Value(address);
  static Insertable<AndroidPrinterProfile> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? name,
    Expression<String>? transport,
    Expression<String>? language,
    Expression<String>? address,
    Expression<String>? portId,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (name != null) 'name': name,
      if (transport != null) 'transport': transport,
      if (language != null) 'language': language,
      if (address != null) 'address': address,
      if (portId != null) 'port_id': portId,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AndroidPrinterProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? name,
    Value<String>? transport,
    Value<String>? language,
    Value<String>? address,
    Value<String?>? portId,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return AndroidPrinterProfilesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      transport: transport ?? this.transport,
      language: language ?? this.language,
      address: address ?? this.address,
      portId: portId ?? this.portId,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (transport.present) {
      map['transport'] = Variable<String>(transport.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (portId.present) {
      map['port_id'] = Variable<String>(portId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AndroidPrinterProfilesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('transport: $transport, ')
          ..write('language: $language, ')
          ..write('address: $address, ')
          ..write('portId: $portId, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflinePrintLogsTable extends OfflinePrintLogs
    with TableInfo<$OfflinePrintLogsTable, OfflinePrintLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflinePrintLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printJobIdMeta = const VerificationMeta(
    'printJobId',
  );
  @override
  late final GeneratedColumn<String> printJobId = GeneratedColumn<String>(
    'print_job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    printJobId,
    payloadJson,
    syncStatus,
    createdAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_print_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflinePrintLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('print_job_id')) {
      context.handle(
        _printJobIdMeta,
        printJobId.isAcceptableOrUnknown(
          data['print_job_id']!,
          _printJobIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_printJobIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, id};
  @override
  OfflinePrintLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflinePrintLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      printJobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}print_job_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $OfflinePrintLogsTable createAlias(String alias) {
    return $OfflinePrintLogsTable(attachedDatabase, alias);
  }
}

class OfflinePrintLog extends DataClass implements Insertable<OfflinePrintLog> {
  final String id;
  final String tenantId;
  final String printJobId;
  final String payloadJson;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime? lastSyncedAt;
  const OfflinePrintLog({
    required this.id,
    required this.tenantId,
    required this.printJobId,
    required this.payloadJson,
    required this.syncStatus,
    required this.createdAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['print_job_id'] = Variable<String>(printJobId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  OfflinePrintLogsCompanion toCompanion(bool nullToAbsent) {
    return OfflinePrintLogsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      printJobId: Value(printJobId),
      payloadJson: Value(payloadJson),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory OfflinePrintLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflinePrintLog(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      printJobId: serializer.fromJson<String>(json['printJobId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'printJobId': serializer.toJson<String>(printJobId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  OfflinePrintLog copyWith({
    String? id,
    String? tenantId,
    String? printJobId,
    String? payloadJson,
    String? syncStatus,
    DateTime? createdAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => OfflinePrintLog(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    printJobId: printJobId ?? this.printJobId,
    payloadJson: payloadJson ?? this.payloadJson,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  OfflinePrintLog copyWithCompanion(OfflinePrintLogsCompanion data) {
    return OfflinePrintLog(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      printJobId: data.printJobId.present
          ? data.printJobId.value
          : this.printJobId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflinePrintLog(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('printJobId: $printJobId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    printJobId,
    payloadJson,
    syncStatus,
    createdAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflinePrintLog &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.printJobId == this.printJobId &&
          other.payloadJson == this.payloadJson &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class OfflinePrintLogsCompanion extends UpdateCompanion<OfflinePrintLog> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> printJobId;
  final Value<String> payloadJson;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const OfflinePrintLogsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.printJobId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflinePrintLogsCompanion.insert({
    required String id,
    required String tenantId,
    required String printJobId,
    required String payloadJson,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       printJobId = Value(printJobId),
       payloadJson = Value(payloadJson);
  static Insertable<OfflinePrintLog> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? printJobId,
    Expression<String>? payloadJson,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (printJobId != null) 'print_job_id': printJobId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflinePrintLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? printJobId,
    Value<String>? payloadJson,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return OfflinePrintLogsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      printJobId: printJobId ?? this.printJobId,
      payloadJson: payloadJson ?? this.payloadJson,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (printJobId.present) {
      map['print_job_id'] = Variable<String>(printJobId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflinePrintLogsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('printJobId: $printJobId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLabelPreviewsTable extends LocalLabelPreviews
    with TableInfo<$LocalLabelPreviewsTable, LocalLabelPreview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLabelPreviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionJsonMeta = const VerificationMeta(
    'definitionJson',
  );
  @override
  late final GeneratedColumn<String> definitionJson = GeneratedColumn<String>(
    'definition_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    definitionJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_label_previews';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLabelPreview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('definition_json')) {
      context.handle(
        _definitionJsonMeta,
        definitionJson.isAcceptableOrUnknown(
          data['definition_json']!,
          _definitionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, id};
  @override
  LocalLabelPreview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLabelPreview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      definitionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalLabelPreviewsTable createAlias(String alias) {
    return $LocalLabelPreviewsTable(attachedDatabase, alias);
  }
}

class LocalLabelPreview extends DataClass
    implements Insertable<LocalLabelPreview> {
  final String id;
  final String tenantId;
  final String definitionJson;
  final DateTime updatedAt;
  const LocalLabelPreview({
    required this.id,
    required this.tenantId,
    required this.definitionJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['definition_json'] = Variable<String>(definitionJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalLabelPreviewsCompanion toCompanion(bool nullToAbsent) {
    return LocalLabelPreviewsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      definitionJson: Value(definitionJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalLabelPreview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLabelPreview(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      definitionJson: serializer.fromJson<String>(json['definitionJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'definitionJson': serializer.toJson<String>(definitionJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalLabelPreview copyWith({
    String? id,
    String? tenantId,
    String? definitionJson,
    DateTime? updatedAt,
  }) => LocalLabelPreview(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    definitionJson: definitionJson ?? this.definitionJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalLabelPreview copyWithCompanion(LocalLabelPreviewsCompanion data) {
    return LocalLabelPreview(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      definitionJson: data.definitionJson.present
          ? data.definitionJson.value
          : this.definitionJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLabelPreview(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, definitionJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLabelPreview &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.definitionJson == this.definitionJson &&
          other.updatedAt == this.updatedAt);
}

class LocalLabelPreviewsCompanion extends UpdateCompanion<LocalLabelPreview> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> definitionJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalLabelPreviewsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.definitionJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLabelPreviewsCompanion.insert({
    required String id,
    required String tenantId,
    required String definitionJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       definitionJson = Value(definitionJson);
  static Insertable<LocalLabelPreview> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? definitionJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (definitionJson != null) 'definition_json': definitionJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLabelPreviewsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? definitionJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalLabelPreviewsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      definitionJson: definitionJson ?? this.definitionJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (definitionJson.present) {
      map['definition_json'] = Variable<String>(definitionJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLabelPreviewsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManagedRequestDraftsTable extends ManagedRequestDrafts
    with TableInfo<$ManagedRequestDraftsTable, ManagedRequestDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagedRequestDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestTypeMeta = const VerificationMeta(
    'requestType',
  );
  @override
  late final GeneratedColumn<String> requestType = GeneratedColumn<String>(
    'request_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    requestType,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'managed_request_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagedRequestDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('request_type')) {
      context.handle(
        _requestTypeMeta,
        requestType.isAcceptableOrUnknown(
          data['request_type']!,
          _requestTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, id};
  @override
  ManagedRequestDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagedRequestDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      requestType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ManagedRequestDraftsTable createAlias(String alias) {
    return $ManagedRequestDraftsTable(attachedDatabase, alias);
  }
}

class ManagedRequestDraft extends DataClass
    implements Insertable<ManagedRequestDraft> {
  final String id;
  final String tenantId;
  final String requestType;
  final String payloadJson;
  final DateTime updatedAt;
  const ManagedRequestDraft({
    required this.id,
    required this.tenantId,
    required this.requestType,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['request_type'] = Variable<String>(requestType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ManagedRequestDraftsCompanion toCompanion(bool nullToAbsent) {
    return ManagedRequestDraftsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      requestType: Value(requestType),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ManagedRequestDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagedRequestDraft(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      requestType: serializer.fromJson<String>(json['requestType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'requestType': serializer.toJson<String>(requestType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ManagedRequestDraft copyWith({
    String? id,
    String? tenantId,
    String? requestType,
    String? payloadJson,
    DateTime? updatedAt,
  }) => ManagedRequestDraft(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    requestType: requestType ?? this.requestType,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ManagedRequestDraft copyWithCompanion(ManagedRequestDraftsCompanion data) {
    return ManagedRequestDraft(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      requestType: data.requestType.present
          ? data.requestType.value
          : this.requestType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagedRequestDraft(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('requestType: $requestType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tenantId, requestType, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagedRequestDraft &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.requestType == this.requestType &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class ManagedRequestDraftsCompanion
    extends UpdateCompanion<ManagedRequestDraft> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> requestType;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ManagedRequestDraftsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.requestType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManagedRequestDraftsCompanion.insert({
    required String id,
    required String tenantId,
    required String requestType,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       requestType = Value(requestType),
       payloadJson = Value(payloadJson);
  static Insertable<ManagedRequestDraft> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? requestType,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (requestType != null) 'request_type': requestType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManagedRequestDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? requestType,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ManagedRequestDraftsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      requestType: requestType ?? this.requestType,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (requestType.present) {
      map['request_type'] = Variable<String>(requestType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManagedRequestDraftsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('requestType: $requestType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AndroidCacheDatabase extends GeneratedDatabase {
  _$AndroidCacheDatabase(QueryExecutor e) : super(e);
  $AndroidCacheDatabaseManager get managers =>
      $AndroidCacheDatabaseManager(this);
  late final $CachedPartsTable cachedParts = $CachedPartsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $AndroidPrintJobsTable androidPrintJobs = $AndroidPrintJobsTable(
    this,
  );
  late final $AndroidPrinterProfilesTable androidPrinterProfiles =
      $AndroidPrinterProfilesTable(this);
  late final $OfflinePrintLogsTable offlinePrintLogs = $OfflinePrintLogsTable(
    this,
  );
  late final $LocalLabelPreviewsTable localLabelPreviews =
      $LocalLabelPreviewsTable(this);
  late final $ManagedRequestDraftsTable managedRequestDrafts =
      $ManagedRequestDraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedParts,
    syncOutbox,
    syncConflicts,
    syncMetadata,
    androidPrintJobs,
    androidPrinterProfiles,
    offlinePrintLogs,
    localLabelPreviews,
    managedRequestDrafts,
  ];
}

typedef $$CachedPartsTableCreateCompanionBuilder =
    CachedPartsCompanion Function({
      required String id,
      required String tenantId,
      required String payloadJson,
      required int serverVersion,
      Value<bool> deleted,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<String?> sourceDevice,
      Value<int> serverGeneration,
      Value<int> rowid,
    });
typedef $$CachedPartsTableUpdateCompanionBuilder =
    CachedPartsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> payloadJson,
      Value<int> serverVersion,
      Value<bool> deleted,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncedAt,
      Value<String?> sourceDevice,
      Value<int> serverGeneration,
      Value<int> rowid,
    });

class $$CachedPartsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $CachedPartsTable> {
  $$CachedPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverGeneration => $composableBuilder(
    column: $table.serverGeneration,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPartsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $CachedPartsTable> {
  $$CachedPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverGeneration => $composableBuilder(
    column: $table.serverGeneration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPartsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $CachedPartsTable> {
  $$CachedPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverGeneration => $composableBuilder(
    column: $table.serverGeneration,
    builder: (column) => column,
  );
}

class $$CachedPartsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $CachedPartsTable,
          CachedPart,
          $$CachedPartsTableFilterComposer,
          $$CachedPartsTableOrderingComposer,
          $$CachedPartsTableAnnotationComposer,
          $$CachedPartsTableCreateCompanionBuilder,
          $$CachedPartsTableUpdateCompanionBuilder,
          (
            CachedPart,
            BaseReferences<
              _$AndroidCacheDatabase,
              $CachedPartsTable,
              CachedPart
            >,
          ),
          CachedPart,
          PrefetchHooks Function()
        > {
  $$CachedPartsTableTableManager(
    _$AndroidCacheDatabase db,
    $CachedPartsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<int> serverGeneration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPartsCompanion(
                id: id,
                tenantId: tenantId,
                payloadJson: payloadJson,
                serverVersion: serverVersion,
                deleted: deleted,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                sourceDevice: sourceDevice,
                serverGeneration: serverGeneration,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String payloadJson,
                required int serverVersion,
                Value<bool> deleted = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<int> serverGeneration = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPartsCompanion.insert(
                id: id,
                tenantId: tenantId,
                payloadJson: payloadJson,
                serverVersion: serverVersion,
                deleted: deleted,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                sourceDevice: sourceDevice,
                serverGeneration: serverGeneration,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $CachedPartsTable,
      CachedPart,
      $$CachedPartsTableFilterComposer,
      $$CachedPartsTableOrderingComposer,
      $$CachedPartsTableAnnotationComposer,
      $$CachedPartsTableCreateCompanionBuilder,
      $$CachedPartsTableUpdateCompanionBuilder,
      (
        CachedPart,
        BaseReferences<_$AndroidCacheDatabase, $CachedPartsTable, CachedPart>,
      ),
      CachedPart,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String tenantId,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      Value<int?> baseVersion,
      required String idempotencyKey,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<String?> lastError,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int?> baseVersion,
      Value<String> idempotencyKey,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<String?> lastError,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<
              _$AndroidCacheDatabase,
              $SyncOutboxTable,
              SyncOutboxData
            >,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(
    _$AndroidCacheDatabase db,
    $SyncOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                tenantId: tenantId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                baseVersion: baseVersion,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                Value<int?> baseVersion = const Value.absent(),
                required String idempotencyKey,
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                tenantId: tenantId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                baseVersion: baseVersion,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<
          _$AndroidCacheDatabase,
          $SyncOutboxTable,
          SyncOutboxData
        >,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String tenantId,
      required String entityType,
      required String entityId,
      required String localPayloadJson,
      required String serverPayloadJson,
      required String reason,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localPayloadJson,
      Value<String> serverPayloadJson,
      Value<String> reason,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverPayloadJson => $composableBuilder(
    column: $table.serverPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<
              _$AndroidCacheDatabase,
              $SyncConflictsTable,
              SyncConflict
            >,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(
    _$AndroidCacheDatabase db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localPayloadJson = const Value.absent(),
                Value<String> serverPayloadJson = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                tenantId: tenantId,
                entityType: entityType,
                entityId: entityId,
                localPayloadJson: localPayloadJson,
                serverPayloadJson: serverPayloadJson,
                reason: reason,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String entityType,
                required String entityId,
                required String localPayloadJson,
                required String serverPayloadJson,
                required String reason,
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                tenantId: tenantId,
                entityType: entityType,
                entityId: entityId,
                localPayloadJson: localPayloadJson,
                serverPayloadJson: serverPayloadJson,
                reason: reason,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<
          _$AndroidCacheDatabase,
          $SyncConflictsTable,
          SyncConflict
        >,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String tenantId,
      Value<String?> pullCursor,
      Value<int> generation,
      Value<DateTime?> lastPulledAt,
      Value<String> alignmentStatus,
      Value<String?> lastAlignmentReport,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> tenantId,
      Value<String?> pullCursor,
      Value<int> generation,
      Value<DateTime?> lastPulledAt,
      Value<String> alignmentStatus,
      Value<String?> lastAlignmentReport,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAlignmentReport => $composableBuilder(
    column: $table.lastAlignmentReport,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAlignmentReport => $composableBuilder(
    column: $table.lastAlignmentReport,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generation => $composableBuilder(
    column: $table.generation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAlignmentReport => $composableBuilder(
    column: $table.lastAlignmentReport,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<
              _$AndroidCacheDatabase,
              $SyncMetadataTable,
              SyncMetadataData
            >,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(
    _$AndroidCacheDatabase db,
    $SyncMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tenantId = const Value.absent(),
                Value<String?> pullCursor = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<String> alignmentStatus = const Value.absent(),
                Value<String?> lastAlignmentReport = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                tenantId: tenantId,
                pullCursor: pullCursor,
                generation: generation,
                lastPulledAt: lastPulledAt,
                alignmentStatus: alignmentStatus,
                lastAlignmentReport: lastAlignmentReport,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tenantId,
                Value<String?> pullCursor = const Value.absent(),
                Value<int> generation = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<String> alignmentStatus = const Value.absent(),
                Value<String?> lastAlignmentReport = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                tenantId: tenantId,
                pullCursor: pullCursor,
                generation: generation,
                lastPulledAt: lastPulledAt,
                alignmentStatus: alignmentStatus,
                lastAlignmentReport: lastAlignmentReport,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<
          _$AndroidCacheDatabase,
          $SyncMetadataTable,
          SyncMetadataData
        >,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$AndroidPrintJobsTableCreateCompanionBuilder =
    AndroidPrintJobsCompanion Function({
      required String id,
      required String tenantId,
      required String printerId,
      required String payload,
      required int quantity,
      required String state,
      Value<bool> resultUncertain,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AndroidPrintJobsTableUpdateCompanionBuilder =
    AndroidPrintJobsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> printerId,
      Value<String> payload,
      Value<int> quantity,
      Value<String> state,
      Value<bool> resultUncertain,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AndroidPrintJobsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrintJobsTable> {
  $$AndroidPrintJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printerId => $composableBuilder(
    column: $table.printerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resultUncertain => $composableBuilder(
    column: $table.resultUncertain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AndroidPrintJobsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrintJobsTable> {
  $$AndroidPrintJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printerId => $composableBuilder(
    column: $table.printerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resultUncertain => $composableBuilder(
    column: $table.resultUncertain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AndroidPrintJobsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrintJobsTable> {
  $$AndroidPrintJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get printerId =>
      $composableBuilder(column: $table.printerId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get resultUncertain => $composableBuilder(
    column: $table.resultUncertain,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AndroidPrintJobsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $AndroidPrintJobsTable,
          AndroidPrintJob,
          $$AndroidPrintJobsTableFilterComposer,
          $$AndroidPrintJobsTableOrderingComposer,
          $$AndroidPrintJobsTableAnnotationComposer,
          $$AndroidPrintJobsTableCreateCompanionBuilder,
          $$AndroidPrintJobsTableUpdateCompanionBuilder,
          (
            AndroidPrintJob,
            BaseReferences<
              _$AndroidCacheDatabase,
              $AndroidPrintJobsTable,
              AndroidPrintJob
            >,
          ),
          AndroidPrintJob,
          PrefetchHooks Function()
        > {
  $$AndroidPrintJobsTableTableManager(
    _$AndroidCacheDatabase db,
    $AndroidPrintJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AndroidPrintJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AndroidPrintJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AndroidPrintJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> printerId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<bool> resultUncertain = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AndroidPrintJobsCompanion(
                id: id,
                tenantId: tenantId,
                printerId: printerId,
                payload: payload,
                quantity: quantity,
                state: state,
                resultUncertain: resultUncertain,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String printerId,
                required String payload,
                required int quantity,
                required String state,
                Value<bool> resultUncertain = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AndroidPrintJobsCompanion.insert(
                id: id,
                tenantId: tenantId,
                printerId: printerId,
                payload: payload,
                quantity: quantity,
                state: state,
                resultUncertain: resultUncertain,
                attempts: attempts,
                lastError: lastError,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AndroidPrintJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $AndroidPrintJobsTable,
      AndroidPrintJob,
      $$AndroidPrintJobsTableFilterComposer,
      $$AndroidPrintJobsTableOrderingComposer,
      $$AndroidPrintJobsTableAnnotationComposer,
      $$AndroidPrintJobsTableCreateCompanionBuilder,
      $$AndroidPrintJobsTableUpdateCompanionBuilder,
      (
        AndroidPrintJob,
        BaseReferences<
          _$AndroidCacheDatabase,
          $AndroidPrintJobsTable,
          AndroidPrintJob
        >,
      ),
      AndroidPrintJob,
      PrefetchHooks Function()
    >;
typedef $$AndroidPrinterProfilesTableCreateCompanionBuilder =
    AndroidPrinterProfilesCompanion Function({
      required String id,
      required String tenantId,
      required String name,
      required String transport,
      required String language,
      required String address,
      Value<String?> portId,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$AndroidPrinterProfilesTableUpdateCompanionBuilder =
    AndroidPrinterProfilesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> name,
      Value<String> transport,
      Value<String> language,
      Value<String> address,
      Value<String?> portId,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$AndroidPrinterProfilesTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrinterProfilesTable> {
  $$AndroidPrinterProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portId => $composableBuilder(
    column: $table.portId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AndroidPrinterProfilesTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrinterProfilesTable> {
  $$AndroidPrinterProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portId => $composableBuilder(
    column: $table.portId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AndroidPrinterProfilesTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $AndroidPrinterProfilesTable> {
  $$AndroidPrinterProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get transport =>
      $composableBuilder(column: $table.transport, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get portId =>
      $composableBuilder(column: $table.portId, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$AndroidPrinterProfilesTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $AndroidPrinterProfilesTable,
          AndroidPrinterProfile,
          $$AndroidPrinterProfilesTableFilterComposer,
          $$AndroidPrinterProfilesTableOrderingComposer,
          $$AndroidPrinterProfilesTableAnnotationComposer,
          $$AndroidPrinterProfilesTableCreateCompanionBuilder,
          $$AndroidPrinterProfilesTableUpdateCompanionBuilder,
          (
            AndroidPrinterProfile,
            BaseReferences<
              _$AndroidCacheDatabase,
              $AndroidPrinterProfilesTable,
              AndroidPrinterProfile
            >,
          ),
          AndroidPrinterProfile,
          PrefetchHooks Function()
        > {
  $$AndroidPrinterProfilesTableTableManager(
    _$AndroidCacheDatabase db,
    $AndroidPrinterProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AndroidPrinterProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AndroidPrinterProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AndroidPrinterProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> transport = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> portId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AndroidPrinterProfilesCompanion(
                id: id,
                tenantId: tenantId,
                name: name,
                transport: transport,
                language: language,
                address: address,
                portId: portId,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String name,
                required String transport,
                required String language,
                required String address,
                Value<String?> portId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AndroidPrinterProfilesCompanion.insert(
                id: id,
                tenantId: tenantId,
                name: name,
                transport: transport,
                language: language,
                address: address,
                portId: portId,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AndroidPrinterProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $AndroidPrinterProfilesTable,
      AndroidPrinterProfile,
      $$AndroidPrinterProfilesTableFilterComposer,
      $$AndroidPrinterProfilesTableOrderingComposer,
      $$AndroidPrinterProfilesTableAnnotationComposer,
      $$AndroidPrinterProfilesTableCreateCompanionBuilder,
      $$AndroidPrinterProfilesTableUpdateCompanionBuilder,
      (
        AndroidPrinterProfile,
        BaseReferences<
          _$AndroidCacheDatabase,
          $AndroidPrinterProfilesTable,
          AndroidPrinterProfile
        >,
      ),
      AndroidPrinterProfile,
      PrefetchHooks Function()
    >;
typedef $$OfflinePrintLogsTableCreateCompanionBuilder =
    OfflinePrintLogsCompanion Function({
      required String id,
      required String tenantId,
      required String printJobId,
      required String payloadJson,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$OfflinePrintLogsTableUpdateCompanionBuilder =
    OfflinePrintLogsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> printJobId,
      Value<String> payloadJson,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$OfflinePrintLogsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $OfflinePrintLogsTable> {
  $$OfflinePrintLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printJobId => $composableBuilder(
    column: $table.printJobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflinePrintLogsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $OfflinePrintLogsTable> {
  $$OfflinePrintLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printJobId => $composableBuilder(
    column: $table.printJobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflinePrintLogsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $OfflinePrintLogsTable> {
  $$OfflinePrintLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get printJobId => $composableBuilder(
    column: $table.printJobId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$OfflinePrintLogsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $OfflinePrintLogsTable,
          OfflinePrintLog,
          $$OfflinePrintLogsTableFilterComposer,
          $$OfflinePrintLogsTableOrderingComposer,
          $$OfflinePrintLogsTableAnnotationComposer,
          $$OfflinePrintLogsTableCreateCompanionBuilder,
          $$OfflinePrintLogsTableUpdateCompanionBuilder,
          (
            OfflinePrintLog,
            BaseReferences<
              _$AndroidCacheDatabase,
              $OfflinePrintLogsTable,
              OfflinePrintLog
            >,
          ),
          OfflinePrintLog,
          PrefetchHooks Function()
        > {
  $$OfflinePrintLogsTableTableManager(
    _$AndroidCacheDatabase db,
    $OfflinePrintLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflinePrintLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflinePrintLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflinePrintLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> printJobId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflinePrintLogsCompanion(
                id: id,
                tenantId: tenantId,
                printJobId: printJobId,
                payloadJson: payloadJson,
                syncStatus: syncStatus,
                createdAt: createdAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String printJobId,
                required String payloadJson,
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflinePrintLogsCompanion.insert(
                id: id,
                tenantId: tenantId,
                printJobId: printJobId,
                payloadJson: payloadJson,
                syncStatus: syncStatus,
                createdAt: createdAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflinePrintLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $OfflinePrintLogsTable,
      OfflinePrintLog,
      $$OfflinePrintLogsTableFilterComposer,
      $$OfflinePrintLogsTableOrderingComposer,
      $$OfflinePrintLogsTableAnnotationComposer,
      $$OfflinePrintLogsTableCreateCompanionBuilder,
      $$OfflinePrintLogsTableUpdateCompanionBuilder,
      (
        OfflinePrintLog,
        BaseReferences<
          _$AndroidCacheDatabase,
          $OfflinePrintLogsTable,
          OfflinePrintLog
        >,
      ),
      OfflinePrintLog,
      PrefetchHooks Function()
    >;
typedef $$LocalLabelPreviewsTableCreateCompanionBuilder =
    LocalLabelPreviewsCompanion Function({
      required String id,
      required String tenantId,
      required String definitionJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalLabelPreviewsTableUpdateCompanionBuilder =
    LocalLabelPreviewsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> definitionJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalLabelPreviewsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $LocalLabelPreviewsTable> {
  $$LocalLabelPreviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLabelPreviewsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $LocalLabelPreviewsTable> {
  $$LocalLabelPreviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLabelPreviewsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $LocalLabelPreviewsTable> {
  $$LocalLabelPreviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalLabelPreviewsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $LocalLabelPreviewsTable,
          LocalLabelPreview,
          $$LocalLabelPreviewsTableFilterComposer,
          $$LocalLabelPreviewsTableOrderingComposer,
          $$LocalLabelPreviewsTableAnnotationComposer,
          $$LocalLabelPreviewsTableCreateCompanionBuilder,
          $$LocalLabelPreviewsTableUpdateCompanionBuilder,
          (
            LocalLabelPreview,
            BaseReferences<
              _$AndroidCacheDatabase,
              $LocalLabelPreviewsTable,
              LocalLabelPreview
            >,
          ),
          LocalLabelPreview,
          PrefetchHooks Function()
        > {
  $$LocalLabelPreviewsTableTableManager(
    _$AndroidCacheDatabase db,
    $LocalLabelPreviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLabelPreviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLabelPreviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLabelPreviewsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> definitionJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLabelPreviewsCompanion(
                id: id,
                tenantId: tenantId,
                definitionJson: definitionJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String definitionJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLabelPreviewsCompanion.insert(
                id: id,
                tenantId: tenantId,
                definitionJson: definitionJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLabelPreviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $LocalLabelPreviewsTable,
      LocalLabelPreview,
      $$LocalLabelPreviewsTableFilterComposer,
      $$LocalLabelPreviewsTableOrderingComposer,
      $$LocalLabelPreviewsTableAnnotationComposer,
      $$LocalLabelPreviewsTableCreateCompanionBuilder,
      $$LocalLabelPreviewsTableUpdateCompanionBuilder,
      (
        LocalLabelPreview,
        BaseReferences<
          _$AndroidCacheDatabase,
          $LocalLabelPreviewsTable,
          LocalLabelPreview
        >,
      ),
      LocalLabelPreview,
      PrefetchHooks Function()
    >;
typedef $$ManagedRequestDraftsTableCreateCompanionBuilder =
    ManagedRequestDraftsCompanion Function({
      required String id,
      required String tenantId,
      required String requestType,
      required String payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ManagedRequestDraftsTableUpdateCompanionBuilder =
    ManagedRequestDraftsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> requestType,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ManagedRequestDraftsTableFilterComposer
    extends Composer<_$AndroidCacheDatabase, $ManagedRequestDraftsTable> {
  $$ManagedRequestDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ManagedRequestDraftsTableOrderingComposer
    extends Composer<_$AndroidCacheDatabase, $ManagedRequestDraftsTable> {
  $$ManagedRequestDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManagedRequestDraftsTableAnnotationComposer
    extends Composer<_$AndroidCacheDatabase, $ManagedRequestDraftsTable> {
  $$ManagedRequestDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ManagedRequestDraftsTableTableManager
    extends
        RootTableManager<
          _$AndroidCacheDatabase,
          $ManagedRequestDraftsTable,
          ManagedRequestDraft,
          $$ManagedRequestDraftsTableFilterComposer,
          $$ManagedRequestDraftsTableOrderingComposer,
          $$ManagedRequestDraftsTableAnnotationComposer,
          $$ManagedRequestDraftsTableCreateCompanionBuilder,
          $$ManagedRequestDraftsTableUpdateCompanionBuilder,
          (
            ManagedRequestDraft,
            BaseReferences<
              _$AndroidCacheDatabase,
              $ManagedRequestDraftsTable,
              ManagedRequestDraft
            >,
          ),
          ManagedRequestDraft,
          PrefetchHooks Function()
        > {
  $$ManagedRequestDraftsTableTableManager(
    _$AndroidCacheDatabase db,
    $ManagedRequestDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManagedRequestDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManagedRequestDraftsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ManagedRequestDraftsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> requestType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagedRequestDraftsCompanion(
                id: id,
                tenantId: tenantId,
                requestType: requestType,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String requestType,
                required String payloadJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagedRequestDraftsCompanion.insert(
                id: id,
                tenantId: tenantId,
                requestType: requestType,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManagedRequestDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AndroidCacheDatabase,
      $ManagedRequestDraftsTable,
      ManagedRequestDraft,
      $$ManagedRequestDraftsTableFilterComposer,
      $$ManagedRequestDraftsTableOrderingComposer,
      $$ManagedRequestDraftsTableAnnotationComposer,
      $$ManagedRequestDraftsTableCreateCompanionBuilder,
      $$ManagedRequestDraftsTableUpdateCompanionBuilder,
      (
        ManagedRequestDraft,
        BaseReferences<
          _$AndroidCacheDatabase,
          $ManagedRequestDraftsTable,
          ManagedRequestDraft
        >,
      ),
      ManagedRequestDraft,
      PrefetchHooks Function()
    >;

class $AndroidCacheDatabaseManager {
  final _$AndroidCacheDatabase _db;
  $AndroidCacheDatabaseManager(this._db);
  $$CachedPartsTableTableManager get cachedParts =>
      $$CachedPartsTableTableManager(_db, _db.cachedParts);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$AndroidPrintJobsTableTableManager get androidPrintJobs =>
      $$AndroidPrintJobsTableTableManager(_db, _db.androidPrintJobs);
  $$AndroidPrinterProfilesTableTableManager get androidPrinterProfiles =>
      $$AndroidPrinterProfilesTableTableManager(
        _db,
        _db.androidPrinterProfiles,
      );
  $$OfflinePrintLogsTableTableManager get offlinePrintLogs =>
      $$OfflinePrintLogsTableTableManager(_db, _db.offlinePrintLogs);
  $$LocalLabelPreviewsTableTableManager get localLabelPreviews =>
      $$LocalLabelPreviewsTableTableManager(_db, _db.localLabelPreviews);
  $$ManagedRequestDraftsTableTableManager get managedRequestDrafts =>
      $$ManagedRequestDraftsTableTableManager(_db, _db.managedRequestDrafts);
}
