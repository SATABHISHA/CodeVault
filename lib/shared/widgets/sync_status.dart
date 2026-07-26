import 'package:codevault/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';

enum SyncState { synced, syncing, offline, alignmentRequired }

class SyncStatus extends StatelessWidget {
  const SyncStatus({required this.state, super.key});
  final SyncState state;
  @override
  Widget build(BuildContext context) {
    final value = switch (state) {
      SyncState.synced => ('Synced', StatusTone.success),
      SyncState.syncing => ('Syncing', StatusTone.info),
      SyncState.offline => ('Offline', StatusTone.warning),
      SyncState.alignmentRequired => ('Alignment required', StatusTone.error),
    };
    return StatusBadge(label: value.$1, tone: value.$2);
  }
}
