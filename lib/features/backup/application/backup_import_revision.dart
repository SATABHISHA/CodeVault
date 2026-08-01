import 'package:flutter/foundation.dart';

/// Notifies long-lived screens that a successful backup import changed the
/// active tenant's local data. Database contents remain the source of truth.
final backupImportRevision = ValueNotifier<int>(0);

void notifyBackupImported() {
  backupImportRevision.value++;
}
