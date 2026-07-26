import 'package:flutter/material.dart';

class SearchSelector<T extends Object> extends StatelessWidget {
  const SearchSelector({
    required this.options,
    required this.labelFor,
    required this.onSelected,
    this.label = 'Search',
    super.key,
  });
  final Iterable<T> options;
  final String Function(T) labelFor;
  final ValueChanged<T> onSelected;
  final String label;
  @override
  Widget build(BuildContext context) => Autocomplete<T>(
    optionsBuilder: (value) {
      final query = value.text.toLowerCase();
      return options.where(
        (item) => labelFor(item).toLowerCase().contains(query),
      );
    },
    displayStringForOption: labelFor,
    onSelected: onSelected,
    fieldViewBuilder: (context, controller, node, onSubmit) => TextField(
      controller: controller,
      focusNode: node,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.search),
      ),
    ),
  );
}
