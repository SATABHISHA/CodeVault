import 'package:flutter/material.dart';

import '../../features/backup/data/managed_request_service.dart';
import 'app_text_field.dart';

enum RequestType { backup, restore }

Future<void> showAnimatedRequestDialog(
  BuildContext context, {
  required RequestType type,
  Future<void> Function(ManagedRequestInput input)? onSubmit,
  String platform = 'android',
  String deviceName = 'CodeVault Android',
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Close request dialog',
  transitionDuration: const Duration(milliseconds: 220),
  pageBuilder: (context, animation, secondaryAnimation) => _RequestDialog(
    type: type,
    onSubmit: onSubmit,
    platform: platform,
    deviceName: deviceName,
  ),
  transitionBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
);

class _RequestDialog extends StatefulWidget {
  const _RequestDialog({
    required this.type,
    required this.platform,
    required this.deviceName,
    this.onSubmit,
  });
  final RequestType type;
  final Future<void> Function(ManagedRequestInput input)? onSubmit;
  final String platform;
  final String deviceName;
  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final contact = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final scope = TextEditingController(text: 'parts,templates,print_jobs');
  final reason = TextEditingController();
  final notes = TextEditingController();
  String preference = 'merge';
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.type == RequestType.backup
          ? 'Request managed backup'
          : 'Request managed restore',
    ),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Contact name', controller: contact),
            const SizedBox(height: 10),
            AppTextField(label: 'Email', controller: email),
            const SizedBox(height: 10),
            AppTextField(label: 'Phone', controller: phone),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Requested scope (comma separated)',
              controller: scope,
            ),
            const SizedBox(height: 10),
            AppTextField(label: 'Reason', controller: reason),
            const SizedBox(height: 10),
            AppTextField(label: 'Notes', controller: notes),
            if (widget.type == RequestType.restore) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: preference,
                decoration: const InputDecoration(
                  labelText: 'Restore preference',
                ),
                items: const [
                  DropdownMenuItem(value: 'merge', child: Text('Merge')),
                  DropdownMenuItem(value: 'replace', child: Text('Replace')),
                ],
                onChanged: (value) => setState(() => preference = value!),
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 10),
            const Text(
              'Submission creates a server request and queued SMTP notification. Only the Ahanova Super-Superadmin can execute it.',
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('submit-managed-request'),
        onPressed: busy ? null : _submit,
        child: Text(busy ? 'Submitting…' : 'Submit request'),
      ),
    ],
  );
  Future<void> _submit() async {
    if ([
      contact.text,
      email.text,
      phone.text,
      scope.text,
      reason.text,
    ].any((value) => value.trim().isEmpty)) {
      setState(() => error = 'Complete all required fields.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onSubmit?.call(
        ManagedRequestInput(
          type: widget.type.name,
          contactName: contact.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          scope: scope.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(),
          reason: reason.text.trim(),
          notes: notes.text.trim(),
          restorePreference: widget.type == RequestType.restore
              ? preference
              : null,
          platform: widget.platform,
          deviceName: widget.deviceName,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Request could not be submitted. It was not executed.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
