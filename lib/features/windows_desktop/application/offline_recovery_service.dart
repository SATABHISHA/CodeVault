import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';
import '../domain/local_security.dart';

class RecoveryChallenge {
  const RecoveryChallenge({
    required this.id,
    required this.code,
    required this.expiresAt,
  });
  final String id;
  final String code;
  final DateTime expiresAt;
}

class OfflineRecoveryService {
  OfflineRecoveryService(this.database, {LocalSecurity? security})
    : security = security ?? LocalSecurity();
  final LocalDatabase database;
  final LocalSecurity security;

  Future<RecoveryChallenge> create(
    String adminUsername, {
    bool confirmed = false,
  }) async {
    if (!confirmed) {
      throw StateError('Explicit recovery confirmation is required.');
    }
    final user =
        await (database.select(database.localUsers)..where(
              (row) =>
                  row.username.equals(adminUsername.trim().toLowerCase()) &
                  row.role.equals('admin'),
            ))
            .getSingleOrNull();
    if (user == null || !user.active) {
      throw StateError('Eligible local administrator not found.');
    }
    final code = security.recoveryCode();
    final digest = await security.hashPassword('Recovery-$code');
    final id = const Uuid().v4();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));
    await database
        .into(database.recoveryCodes)
        .insert(
          RecoveryCodesCompanion.insert(
            id: id,
            companyId: user.companyId,
            userId: user.id,
            codeHash: digest.hash,
            codeSalt: digest.salt,
            expiresAt: expiresAt,
          ),
        );
    await database
        .into(database.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            companyId: user.companyId,
            userId: Value(user.id),
            event: 'recovery.created',
            detailsJson: jsonEncode({
              'challengeId': id,
              'expiresAt': expiresAt.toIso8601String(),
            }),
          ),
        );
    return RecoveryChallenge(id: id, code: code, expiresAt: expiresAt);
  }

  Future<bool> consume(String challengeId, String code) async {
    final challenge = await (database.select(
      database.recoveryCodes,
    )..where((row) => row.id.equals(challengeId))).getSingleOrNull();
    if (challenge == null ||
        challenge.usedAt != null ||
        challenge.expiresAt.isBefore(DateTime.now()) ||
        challenge.attempts >= 5) {
      return false;
    }
    final valid = await security.verify(
      'Recovery-$code',
      PasswordDigest(challenge.codeHash, challenge.codeSalt),
    );
    if (!valid) {
      await (database.update(
        database.recoveryCodes,
      )..where((row) => row.id.equals(challengeId))).write(
        RecoveryCodesCompanion(attempts: Value(challenge.attempts + 1)),
      );
      return false;
    }
    await database.transaction(() async {
      await (database.update(database.recoveryCodes)
            ..where((row) => row.id.equals(challengeId)))
          .write(RecoveryCodesCompanion(usedAt: Value(DateTime.now())));
      await (database.update(
        database.localUsers,
      )..where((row) => row.id.equals(challenge.userId))).write(
        const LocalUsersCompanion(
          mustChangePassword: Value(true),
          failedAttempts: Value(0),
          lockedUntil: Value(null),
        ),
      );
    });
    return true;
  }

  Future<bool> resetPassword({
    required String challengeId,
    required String code,
    required String newPassword,
  }) async {
    if (newPassword.length < 12) {
      throw StateError('The new password must contain at least 12 characters.');
    }
    final challenge = await (database.select(
      database.recoveryCodes,
    )..where((row) => row.id.equals(challengeId))).getSingleOrNull();
    if (challenge == null || !await consume(challengeId, code)) return false;
    final digest = await security.hashPassword(newPassword);
    await (database.update(
      database.localUsers,
    )..where((row) => row.id.equals(challenge.userId))).write(
      LocalUsersCompanion(
        passwordHash: Value(digest.hash),
        passwordSalt: Value(digest.salt),
        mustChangePassword: const Value(false),
      ),
    );
    return true;
  }
}
