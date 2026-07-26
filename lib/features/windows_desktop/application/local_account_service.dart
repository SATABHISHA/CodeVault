import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';
import '../domain/local_security.dart';

class LocalLoginResult {
  const LocalLoginResult({required this.user, required this.permissions});
  final LocalUser user;
  final Set<String> permissions;
}

class LocalAccountService {
  LocalAccountService(this.database, {LocalSecurity? security, Uuid? uuid})
    : security = security ?? LocalSecurity(),
      uuid = uuid ?? const Uuid();
  final LocalDatabase database;
  final LocalSecurity security;
  final Uuid uuid;

  Future<String> initializeCompany({
    String? companyId,
    required String name,
    required String username,
    required String displayName,
    required String password,
    String? address,
    String? phone,
    String? email,
  }) async {
    if (await database.isInitialized()) {
      throw StateError('Company is already initialized.');
    }
    final resolvedCompanyId = companyId ?? uuid.v4();
    final userId = uuid.v4();
    final digest = await security.hashPassword(password);
    await database.transaction(() async {
      await database
          .into(database.companies)
          .insert(
            CompaniesCompanion.insert(
              id: resolvedCompanyId,
              name: name.trim(),
              address: Value(address?.trim()),
              phone: Value(phone?.trim()),
              email: Value(email?.trim()),
            ),
          );
      await database
          .into(database.localUsers)
          .insert(
            LocalUsersCompanion.insert(
              id: userId,
              companyId: resolvedCompanyId,
              username: username.trim().toLowerCase(),
              displayName: displayName.trim(),
              passwordHash: digest.hash,
              passwordSalt: digest.salt,
              role: const Value('admin'),
              permissionsJson: Value(jsonEncode(_adminPermissions)),
            ),
          );
      await _audit(resolvedCompanyId, userId, 'company.initialized', {
        'company': name,
      });
    });
    return resolvedCompanyId;
  }

  Future<LocalLoginResult> login(String username, String password) async {
    final normalized = username.trim().toLowerCase();
    final user = await (database.select(
      database.localUsers,
    )..where((row) => row.username.equals(normalized))).getSingleOrNull();
    if (user == null || !user.active) {
      throw StateError('Invalid local credentials.');
    }
    final now = DateTime.now();
    if (user.lockedUntil?.isAfter(now) ?? false) {
      throw StateError('Account is temporarily locked.');
    }
    final valid = await security.verify(
      password,
      PasswordDigest(user.passwordHash, user.passwordSalt),
    );
    if (!valid) {
      final failures = user.failedAttempts + 1;
      await (database.update(
        database.localUsers,
      )..where((row) => row.id.equals(user.id))).write(
        LocalUsersCompanion(
          failedAttempts: Value(failures),
          lockedUntil: Value(
            failures >= 5 ? now.add(const Duration(minutes: 15)) : null,
          ),
        ),
      );
      await _audit(user.companyId, user.id, 'auth.failed', {
        'attempts': failures,
      });
      throw StateError('Invalid local credentials.');
    }
    await (database.update(
      database.localUsers,
    )..where((row) => row.id.equals(user.id))).write(
      const LocalUsersCompanion(
        failedAttempts: Value(0),
        lockedUntil: Value(null),
      ),
    );
    await _audit(user.companyId, user.id, 'auth.login', {});
    return LocalLoginResult(
      user: user,
      permissions: Set<String>.from(jsonDecode(user.permissionsJson) as List),
    );
  }

  Future<String> createUser({
    required String companyId,
    required String actorId,
    required String username,
    required String displayName,
    required Set<String> permissions,
  }) async {
    final temporaryPassword = security.temporaryPassword();
    final digest = await security.hashPassword(temporaryPassword);
    await database
        .into(database.localUsers)
        .insert(
          LocalUsersCompanion.insert(
            id: uuid.v4(),
            companyId: companyId,
            username: username.trim().toLowerCase(),
            displayName: displayName.trim(),
            passwordHash: digest.hash,
            passwordSalt: digest.salt,
            permissionsJson: Value(jsonEncode(permissions.toList()..sort())),
          ),
        );
    await _audit(companyId, actorId, 'user.created', {'username': username});
    return temporaryPassword;
  }

  Future<void> setActive(String userId, bool active, String actorId) async {
    final user = await (database.select(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).getSingle();
    await (database.update(database.localUsers)
          ..where((row) => row.id.equals(userId)))
        .write(LocalUsersCompanion(active: Value(active)));
    await _audit(user.companyId, actorId, 'user.activation_changed', {
      'userId': userId,
      'active': active,
    });
  }

  Future<void> editUser({
    required String userId,
    required String actorId,
    required String displayName,
    required Set<String> permissions,
  }) async {
    final user = await (database.select(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).getSingle();
    await (database.update(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).write(
      LocalUsersCompanion(
        displayName: Value(displayName.trim()),
        permissionsJson: Value(jsonEncode(permissions.toList()..sort())),
      ),
    );
    await _audit(user.companyId, actorId, 'user.updated', {
      'userId': userId,
      'permissions': permissions.toList()..sort(),
    });
  }

  Future<String> resetPassword(String userId, String actorId) async {
    final user = await (database.select(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).getSingle();
    final temporary = security.temporaryPassword();
    final digest = await security.hashPassword(temporary);
    await (database.update(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).write(
      LocalUsersCompanion(
        passwordHash: Value(digest.hash),
        passwordSalt: Value(digest.salt),
        mustChangePassword: const Value(true),
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
      ),
    );
    await _audit(user.companyId, actorId, 'user.password_reset', {
      'userId': userId,
    });
    return temporary;
  }

  Future<void> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    final user = await (database.select(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).getSingle();
    if (!await security.verify(
      currentPassword,
      PasswordDigest(user.passwordHash, user.passwordSalt),
    )) {
      throw StateError('Current password is invalid.');
    }
    final digest = await security.hashPassword(newPassword);
    await (database.update(
      database.localUsers,
    )..where((row) => row.id.equals(userId))).write(
      LocalUsersCompanion(
        passwordHash: Value(digest.hash),
        passwordSalt: Value(digest.salt),
        mustChangePassword: const Value(false),
      ),
    );
    await _audit(user.companyId, user.id, 'auth.password_changed', {});
  }

  Future<void> _audit(
    String companyId,
    String? userId,
    String event,
    Map<String, Object?> details,
  ) => database
      .into(database.auditLogs)
      .insert(
        AuditLogsCompanion.insert(
          companyId: companyId,
          userId: Value(userId),
          event: event,
          detailsJson: jsonEncode(details),
        ),
      );
}

const _adminPermissions = <String>[
  'users.manage',
  'parts.manage',
  'templates.manage',
  'printers.manage',
  'backup.manage',
  'reports.read',
  'print.execute',
];
