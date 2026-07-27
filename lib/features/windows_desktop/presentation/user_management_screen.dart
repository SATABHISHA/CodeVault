import 'package:flutter/material.dart';

import '../application/local_account_service.dart';
import '../application/windows_session.dart';
import '../data/local_database.dart';

class WindowsUserManagementScreen extends StatefulWidget {
  const WindowsUserManagementScreen({super.key});
  @override
  State<WindowsUserManagementScreen> createState() =>
      _WindowsUserManagementScreenState();
}

class _WindowsUserManagementScreenState
    extends State<WindowsUserManagementScreen> {
  List<LocalUser> users = const [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final company = WindowsSession.companyId;
    if (company == null) {
      setState(
        () => error = 'Sign in with the local administrator account first.',
      );
      return;
    }
    final db = LocalDatabase(company);
    try {
      final rows = await db.select(db.localUsers).get();
      if (mounted) {
        setState(() {
          users = rows;
          error = null;
        });
      }
    } finally {
      await db.close();
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5130B7), Color(0xFF00A7C4)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Local team administration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            FilledButton.icon(
              onPressed: WindowsSession.role == 'admin' ? _create : null,
              icon: const Icon(Icons.person_add),
              label: const Text('Create user'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      if (error != null) Card(child: ListTile(title: Text(error!))),
      for (final user in users)
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.displayName.substring(0, 1).toUpperCase()),
            ),
            title: Text(user.displayName),
            subtitle: Text(
              '${user.username} • ${user.role} • ${user.active ? 'active' : 'inactive'}',
            ),
            trailing: user.role == 'admin'
                ? const Chip(label: Text('ADMIN'))
                : Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _reset(user),
                        child: const Text('Reset password'),
                      ),
                      Switch(
                        value: user.active,
                        onChanged: (value) => _active(user, value),
                      ),
                    ],
                  ),
          ),
        ),
    ],
  );

  Future<void> _create() async {
    final name = TextEditingController(), username = TextEditingController();
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Create local user'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    final db = LocalDatabase(WindowsSession.companyId!);
    try {
      final password = await LocalAccountService(db).createUser(
        companyId: WindowsSession.companyId!,
        actorId: WindowsSession.userId!,
        username: username.text,
        displayName: name.text,
        permissions: {'parts.manage', 'print.execute'},
      );
      if (mounted) _credential(password);
    } finally {
      await db.close();
    }
    await _load();
  }

  Future<void> _reset(LocalUser user) async {
    final db = LocalDatabase(WindowsSession.companyId!);
    try {
      final value = await LocalAccountService(
        db,
      ).resetPassword(user.id, WindowsSession.userId!);
      if (mounted) _credential(value);
    } finally {
      await db.close();
    }
  }

  Future<void> _active(LocalUser user, bool value) async {
    final db = LocalDatabase(WindowsSession.companyId!);
    try {
      await LocalAccountService(
        db,
      ).setActive(user.id, value, WindowsSession.userId!);
    } finally {
      await db.close();
    }
    await _load();
  }

  void _credential(String password) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.key),
      title: const Text('Temporary credential'),
      content: SelectableText(password, textAlign: TextAlign.center),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
