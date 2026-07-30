import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.autofillHints,
    this.controller,
    this.suffix,
    super.key,
  });
  final String label;
  final IconData? icon;
  final bool obscureText;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    readOnly: readOnly,
    autofillHints: autofillHints,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
    ),
  );
}
