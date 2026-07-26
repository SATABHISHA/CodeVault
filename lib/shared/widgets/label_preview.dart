import 'package:flutter/material.dart';

class LabelPreview extends StatelessWidget {
  const LabelPreview({
    required this.content,
    this.width = 240,
    this.height = 140,
    super.key,
  });
  final Widget content;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Label preview',
    child: Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black, fontSize: 12),
        child: content,
      ),
    ),
  );
}
