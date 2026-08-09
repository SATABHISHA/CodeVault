import 'dart:convert';

enum LabelLayoutElement {
  singleCompanyName,
  singleCompanyAddress,
  singlePartNumber,
  singleItemName,
  singleModelPort,
  singleDateTime,
  singleBarcode,
  singleCodeData,
  dualLeftCode,
  dualCompanyName,
  dualModel,
  dualPort,
  dualDateTime,
  dualPartNumber,
  dualItemName,
  dualCodeData,
  dualRightCode,
}

class LabelLayoutRect {
  const LabelLayoutRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class LabelLayoutPosition {
  const LabelLayoutPosition({
    required this.x,
    required this.y,
    this.rotation = 0,
  });

  final double x;
  final double y;
  final double rotation;

  LabelLayoutPosition clamp() =>
      // Rotated content can require a small negative normalized origin to put
      // its visible bounding box flush with the top/left label edges. Values
      // may also exceed 1 because text positions retain their legacy slot as
      // the positioning reference while the rendered box wraps its content.
      LabelLayoutPosition(
        x: x.clamp(-20.0, 20.0),
        y: y.clamp(-20.0, 20.0),
        rotation: rotation.isFinite ? rotation : 0,
      );

  Map<String, double> toJson() => {'x': x, 'y': y, 'rotation': rotation};

  static LabelLayoutPosition? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final x = value['x'];
    final y = value['y'];
    final rotation = value['rotation'];
    if (x is! num || y is! num) return null;
    return LabelLayoutPosition(
      x: x.toDouble(),
      y: y.toDouble(),
      rotation: rotation is num ? rotation.toDouble() : 0,
    ).clamp();
  }
}

class LabelLayout {
  const LabelLayout(this.positions);

  final Map<LabelLayoutElement, LabelLayoutPosition> positions;

  factory LabelLayout.defaults() => LabelLayout({
    LabelLayoutElement.singleCompanyName: const LabelLayoutPosition(
      x: 0.02,
      y: 0.02,
    ),
    LabelLayoutElement.singleCompanyAddress: const LabelLayoutPosition(
      x: 0.02,
      y: 0.10,
    ),
    LabelLayoutElement.singlePartNumber: const LabelLayoutPosition(
      x: 0.02,
      y: 0.22,
    ),
    LabelLayoutElement.singleItemName: const LabelLayoutPosition(
      x: 0.02,
      y: 0.30,
    ),
    LabelLayoutElement.singleModelPort: const LabelLayoutPosition(
      x: 0.02,
      y: 0.38,
    ),
    LabelLayoutElement.singleDateTime: const LabelLayoutPosition(
      x: 0.02,
      y: 0.46,
    ),
    LabelLayoutElement.singleBarcode: const LabelLayoutPosition(
      x: 0.02,
      y: 0.54,
    ),
    LabelLayoutElement.singleCodeData: const LabelLayoutPosition(
      x: 0.02,
      y: 0.92,
    ),
    LabelLayoutElement.dualLeftCode: const LabelLayoutPosition(
      x: 0.02,
      y: 0.24,
    ),
    LabelLayoutElement.dualCompanyName: const LabelLayoutPosition(
      x: 0.24,
      y: 0.06,
    ),
    LabelLayoutElement.dualModel: const LabelLayoutPosition(x: 0.24, y: 0.18),
    LabelLayoutElement.dualPort: const LabelLayoutPosition(x: 0.67, y: 0.18),
    LabelLayoutElement.dualDateTime: const LabelLayoutPosition(
      x: 0.24,
      y: 0.30,
    ),
    LabelLayoutElement.dualPartNumber: const LabelLayoutPosition(
      x: 0.24,
      y: 0.42,
    ),
    LabelLayoutElement.dualItemName: const LabelLayoutPosition(
      x: 0.24,
      y: 0.54,
    ),
    LabelLayoutElement.dualCodeData: const LabelLayoutPosition(
      x: 0.24,
      y: 0.66,
    ),
    LabelLayoutElement.dualRightCode: const LabelLayoutPosition(
      x: 0.78,
      y: 0.24,
    ),
  });

  LabelLayoutPosition positionFor(LabelLayoutElement element) =>
      positions[element] ?? LabelLayout.defaults().positions[element]!;

  LabelLayout copyWithElement(
    LabelLayoutElement element,
    LabelLayoutPosition position,
  ) {
    return LabelLayout({...positions, element: position.clamp()});
  }

  String toEncodedJson() {
    final data = <String, Map<String, double>>{};
    for (final entry in positions.entries) {
      data[entry.key.name] = entry.value.clamp().toJson();
    }
    return jsonEncode(data);
  }

  static LabelLayout fromEncodedJson(String? encoded) {
    if (encoded == null || encoded.isEmpty) return LabelLayout.defaults();
    final defaults = LabelLayout.defaults().positions;
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) return LabelLayout.defaults();
    final resolved = <LabelLayoutElement, LabelLayoutPosition>{...defaults};
    for (final entry in decoded.entries) {
      final element = LabelLayoutElement.values
          .where((candidate) => candidate.name == entry.key)
          .firstOrNull;
      if (element == null) continue;
      final position = LabelLayoutPosition.fromJson(entry.value);
      if (position != null) resolved[element] = position;
    }
    return LabelLayout(resolved);
  }
}
