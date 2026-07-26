import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.icon,
    this.obscureText = false,
    this.autofillHints,
    this.controller,
    super.key,
  });
  final String label;
  final IconData? icon;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    autofillHints: autofillHints,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
    ),
  );
}
