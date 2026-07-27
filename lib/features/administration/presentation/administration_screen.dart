import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../data/administration_service.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});
  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final service = AdministrationService();
  Map<String, dynamic>? data;
  String? selectedTenant;
  List<dynamic> users = const [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await service.overview();
      if (mounted) {
        setState(() {
          data = result;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Administration data could not be loaded.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Center(
        child: error == null
            ? const CircularProgressIndicator()
            : _errorState(),
      );
    }
    final metrics = data!['metrics'] as Map<String, dynamic>;
    final tenants = List<dynamic>.from(data!['tenants'] as List? ?? const []);
    final superadmins = List<dynamic>.from(
      data!['superadmins'] as List? ?? const [],
    );
    final role = data!['role'] as String? ?? '';
    final canCreateTenant = role == 'superadmin';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4026A8), Color(0xFF7B3FE4), Color(0xFF00A7C4)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 14,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Administration center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _roleLabel(role),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              if (role == 'super-superadmin')
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5130B7),
                  ),
                  onPressed: _createSuperadmin,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Add superadmin'),
                )
              else if (canCreateTenant)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5130B7),
                  ),
                  onPressed: _createTenant,
                  icon: const Icon(Icons.domain_add),
                  label: const Text('Add company'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 1000 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _metric(
              'Companies',
              metrics['tenants'],
              Icons.apartment,
              const Color(0xFF6047F5),
            ),
            _metric(
              'Active',
              metrics['active_tenants'],
              Icons.verified,
              const Color(0xFF00A86B),
            ),
            _metric(
              'Total users',
              metrics['users'],
              Icons.groups,
              const Color(0xFF008CCF),
            ),
            _metric(
              'Active users',
              metrics['active_users'],
              Icons.person_pin_circle,
              const Color(0xFFFF6B6B),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (role == 'super-superadmin') ...[
          Text(
            'Superadmin organizations',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final raw in superadmins)
            _superadminCard(raw as Map<String, dynamic>),
          const SizedBox(height: 20),
        ],
        Text(
          'Managed companies',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (final raw in tenants)
          _tenantCard(raw as Map<String, dynamic>, canCreateTenant),
        if (selectedTenant != null) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Company users',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (role == 'superadmin')
                    OutlinedButton.icon(
                      onPressed: () => _createUser('tenant-admin'),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Add admin'),
                    ),
                  FilledButton.icon(
                    onPressed: () => _createUser('normal-user'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add user'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                for (final raw in users) _userTile(raw as Map<String, dynamic>),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _metric(String label, dynamic value, IconData icon, Color color) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .14),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(label),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _superadminCard(Map<String, dynamic> organization) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: const CircleAvatar(child: Icon(Icons.hub_outlined)),
      title: Text(
        organization['name'] as String? ?? 'Superadmin organization',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${organization['tenants_count'] ?? 0} companies • '
        '${organization['active_users_count'] ?? 0}/${organization['users_count'] ?? 0} active superadmins',
      ),
      trailing: PopupMenuButton<String>(
        tooltip: 'Change superadmin access',
        onSelected: (status) async {
          await service.superadminStatus(organization['id'] as String, status);
          _load();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'active', child: Text('Activate')),
          PopupMenuItem(value: 'suspended', child: Text('Suspend')),
          PopupMenuItem(value: 'inactive', child: Text('Deactivate')),
        ],
      ),
    ),
  );

  Widget _tenantCard(Map<String, dynamic> tenant, bool canManage) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: CircleAvatar(
        child: Text((tenant['name'] as String).substring(0, 1)),
      ),
      title: Text(
        tenant['name'] as String,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${tenant['users_count']} users • ${tenant['status']}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () => _loadUsers(tenant['id'] as String),
            icon: const Icon(Icons.people_outline),
            label: const Text('Users'),
          ),
          if (canManage)
            PopupMenuButton<String>(
              onSelected: (status) async {
                await service.tenantStatus(tenant['id'] as String, status);
                _load();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'active', child: Text('Activate')),
                PopupMenuItem(value: 'suspended', child: Text('Suspend')),
                PopupMenuItem(value: 'inactive', child: Text('Deactivate')),
              ],
            ),
        ],
      ),
    ),
  );

  Widget _userTile(Map<String, dynamic> user) => ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
    title: Text(user['full_name'] as String),
    subtitle: Text('${user['username']} • ${user['designation'] ?? 'User'}'),
    trailing: Wrap(
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed: () async {
            final password = await service.resetPassword(user['id'] as String);
            if (mounted) _passwordDialog(password);
          },
          child: const Text('Reset password'),
        ),
        PopupMenuButton<String>(
          tooltip: 'Change account access',
          onSelected: (status) async {
            await service.userStatus(
              selectedTenant!,
              user['id'] as String,
              status,
            );
            _loadUsers(selectedTenant!);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'active', child: Text('Activate')),
            PopupMenuItem(value: 'suspended', child: Text('Suspend')),
            PopupMenuItem(value: 'inactive', child: Text('Deactivate')),
          ],
        ),
      ],
    ),
  );

  Future<void> _loadUsers(String tenant) async {
    final result = await service.users(tenant);
    setState(() {
      selectedTenant = tenant;
      users = result['data'] as List<dynamic>;
    });
  }

  Future<void> _createTenant() async {
    final values = await _formDialog('Create company', const [
      'Company name',
      'Administrator name',
      'Admin username',
      'Admin email',
      'Phone',
      'Password',
      'Confirm password',
    ]);
    if (values == null) return;
    try {
      await service.createTenant({
        'name': values[0],
        'admin_name': values[1],
        'admin_username': values[2],
        'admin_email': values[3],
        'phone': values[4],
        'password': values[5],
        'password_confirmation': values[6],
      });
    } catch (exception) {
      if (mounted) _showActionError(exception);
      return;
    }
    await _load();
    if (mounted) await _createdDialog(values[2], values[5]);
  }

  Future<void> _createUser(String role) async {
    final values = await _formDialog(
      role == 'tenant-admin'
          ? 'Create company administrator'
          : 'Create company user',
      const [
        'Full name',
        'Username',
        'Email',
        'Phone',
        'Department',
        'Designation',
        'Password',
        'Confirm password',
      ],
    );
    if (values == null) return;
    try {
      await service.createUser(selectedTenant!, {
        'full_name': values[0],
        'username': values[1],
        'email': values[2],
        'phone': values[3],
        'department': values[4],
        'designation': values[5],
        'role': role,
        'password': values[6],
        'password_confirmation': values[7],
      });
    } catch (exception) {
      if (mounted) _showActionError(exception);
      return;
    }
    await _loadUsers(selectedTenant!);
    if (mounted) await _createdDialog(values[1], values[6]);
  }

  Future<void> _createSuperadmin() async {
    final values = await _formDialog('Create superadmin organization', const [
      'Organization name',
      'Superadmin name',
      'Username',
      'Email',
      'Phone',
      'Password',
      'Confirm password',
    ]);
    if (values == null) return;
    try {
      await service.createSuperadmin({
        'organization_name': values[0],
        'full_name': values[1],
        'username': values[2],
        'email': values[3],
        'phone': values[4],
        'password': values[5],
        'password_confirmation': values[6],
      });
    } catch (exception) {
      if (mounted) _showActionError(exception);
      return;
    }
    await _load();
    if (mounted) await _createdDialog(values[2], values[5]);
  }

  Future<List<String>?> _formDialog(String title, List<String> labels) {
    final controllers = [for (final _ in labels) TextEditingController()];
    final formKey = GlobalKey<FormState>();
    return showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: controllers[i],
                        obscureText: labels[i].toLowerCase().contains(
                          'password',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => _validateField(
                          labels[i],
                          value ?? '',
                          controllers,
                          labels,
                        ),
                        decoration: InputDecoration(labelText: labels[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(
                context,
                controllers.map((item) => item.text.trim()).toList(),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  String? _validateField(
    String label,
    String value,
    List<TextEditingController> controllers,
    List<String> labels,
  ) {
    final normalized = value.trim();
    const optional = {'Phone', 'Department', 'Designation'};
    if (normalized.isEmpty && !optional.contains(label)) {
      return '$label is required.';
    }
    if (label.toLowerCase().contains('email') &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized)) {
      return 'Enter a valid email address.';
    }
    if (label.toLowerCase().contains('username') && normalized.length < 3) {
      return 'Username must contain at least 3 characters.';
    }
    if (label == 'Password') {
      if (normalized.length < 12 ||
          !RegExp(r'[a-z]').hasMatch(normalized) ||
          !RegExp(r'[A-Z]').hasMatch(normalized) ||
          !RegExp(r'\d').hasMatch(normalized) ||
          !RegExp(r'[^A-Za-z0-9]').hasMatch(normalized)) {
        return 'Use 12+ characters with upper, lower, number and symbol.';
      }
    }
    if (label == 'Confirm password') {
      final passwordIndex = labels.indexOf('Password');
      if (passwordIndex < 0 || normalized != controllers[passwordIndex].text) {
        return 'Passwords do not match.';
      }
    }
    return null;
  }

  void _passwordDialog(String password) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.key, size: 42),
      title: const Text('Temporary password generated'),
      content: SelectableText(
        password,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  Future<void> _createdDialog(String username, String password) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.verified_user_outlined, size: 42),
          title: const Text('Account created'),
          content: SelectableText(
            'Username: $username\nPassword: $password',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );

  void _showActionError(Object exception) {
    var message = 'The server did not accept the account details.';
    String? requestId;
    if (exception is DioException) {
      final body = exception.response?.data;
      if (body is Map) {
        requestId = body['request_id']?.toString();
        final errors = body['errors'];
        if (errors is Map) {
          message = errors.values
              .expand((value) => value is List ? value : [value])
              .join('\n');
        } else {
          final apiError = body['error'];
          if (apiError is Map) {
            final details = apiError['details'];
            if (details is Map && details.isNotEmpty) {
              message = details.entries
                  .expand((entry) {
                    final value = entry.value;
                    final messages = value is List ? value : [value];
                    return messages.map((item) => '${entry.key}: $item');
                  })
                  .join('\n');
            } else {
              message = apiError['message']?.toString() ?? message;
            }
          } else {
            message = body['message']?.toString() ?? message;
          }
        }
      } else if (exception.type == DioExceptionType.connectionError ||
          exception.type == DioExceptionType.connectionTimeout) {
        message =
            'Laravel could not be reached. Start the local API and try again.';
      }
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 42,
        ),
        title: const Text('Account was not created'),
        content: Text(
          '$message${requestId == null ? '' : '\n\nRequest: $requestId'}',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review details'),
          ),
        ],
      ),
    );
  }

  Widget _errorState() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.cloud_off, size: 50),
      const SizedBox(height: 12),
      Text(error!),
      TextButton(onPressed: _load, child: const Text('Retry')),
    ],
  );
  String _roleLabel(String role) => switch (role) {
    'super-superadmin' =>
      'Ahanova platform owner • All organizations and tenants',
    'superadmin' => 'Super administrator • Assigned companies',
    'tenant-admin' => 'Company administrator • Users and permissions',
    _ => 'User workspace',
  };
}
