import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

enum CodeSymbology { code128, qr, dataMatrix }

class BarcodeView extends StatelessWidget {
  const BarcodeView({
    required this.data,
    required this.symbology,
    this.color = Colors.black,
    super.key,
  });

  final String data;
  final CodeSymbology symbology;
  final Color color;

  Barcode get _barcode => switch (symbology) {
    CodeSymbology.code128 => Barcode.code128(),
    CodeSymbology.qr => Barcode.qrCode(),
    CodeSymbology.dataMatrix => Barcode.dataMatrix(),
  };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (data.trim().isEmpty) {
        return const Center(child: Text('Enter label data to preview'));
      }
      return CustomPaint(
        painter: _BarcodePainter(barcode: _barcode, data: data, color: color),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
    },
  );
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter({
    required this.barcode,
    required this.data,
    required this.color,
  });

  final Barcode barcode;
  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    try {
      final elements = barcode.make(
        data,
        width: size.width,
        height: size.height,
        drawText: false,
      );
      for (final element in elements) {
        if (element is BarcodeBar && element.black) {
          canvas.drawRect(
            Rect.fromLTWH(
              element.left,
              element.top,
              element.width,
              element.height,
            ),
            paint,
          );
        }
      }
    } on BarcodeException {
      final text = TextPainter(
        text: const TextSpan(
          text: 'Data is not valid for this code type',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      text.paint(canvas, Offset.zero);
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.barcode.runtimeType != barcode.runtimeType ||
      oldDelegate.color != color;
}
