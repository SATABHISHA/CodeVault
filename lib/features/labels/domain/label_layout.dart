import 'dart:convert';

enum LabelLayoutElement {
  singleCompanyName,
  singleCompanyAddress,
  singlePartNumber,
  singleItemName,
  singleModel,
  singlePort,
  // Legacy saved-layout key. Model and Port are now independently movable.
  singleModelPort,
  singleDate,
  singleTime,
  // Legacy saved-layout key. New rendering uses singleDate/singleTime.
  singleDateTime,
  singleBarcode,
  singleCodeData,
  dualLeftCode,
  dualCompanyName,
  dualModel,
  dualPort,
  dualDate,
  dualTime,
  // Legacy saved-layout key. New rendering uses dualDate/dualTime.
  dualDateTime,
  dualPartNumber,
  dualItemName,
  dualCodeData,
  dualRightCode,
  singleSerialNumber,
  dualSerialNumber,
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

  static const double _singleTimeOffsetX = 0.24;
  static const double _dualTimeOffsetX = 0.19;

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
    LabelLayoutElement.singleModel: const LabelLayoutPosition(x: 0.02, y: 0.38),
    LabelLayoutElement.singlePort: const LabelLayoutPosition(x: 0.32, y: 0.38),
    // Keep the serial on the right side of the model row so legacy barcode
    // and code-data positions do not need to move when this field is added.
    LabelLayoutElement.singleSerialNumber: const LabelLayoutPosition(
      x: 2.45,
      y: 0.38,
    ),
    LabelLayoutElement.singleDate: const LabelLayoutPosition(x: 0.02, y: 0.46),
    LabelLayoutElement.singleTime: const LabelLayoutPosition(x: 0.26, y: 0.46),
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
    LabelLayoutElement.dualDate: const LabelLayoutPosition(x: 0.24, y: 0.30),
    LabelLayoutElement.dualTime: const LabelLayoutPosition(x: 0.43, y: 0.30),
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
    LabelLayoutElement.dualSerialNumber: const LabelLayoutPosition(
      x: 0.24,
      y: 0.78,
    ),
    LabelLayoutElement.dualRightCode: const LabelLayoutPosition(
      x: 0.78,
      y: 0.24,
    ),
  });

  LabelLayoutPosition positionFor(LabelLayoutElement element) {
    final directPosition = positions[element];
    if (directPosition != null) return directPosition;

    // Keep callers using the previous combined elements safe while the saved
    // representation migrates to independently positioned Date and Time.
    final legacyPosition = switch (element) {
      LabelLayoutElement.singleDate =>
        positions[LabelLayoutElement.singleDateTime],
      LabelLayoutElement.singleTime => _followingTimePosition(
        positions[LabelLayoutElement.singleDateTime],
        _singleTimeOffsetX,
      ),
      LabelLayoutElement.singleDateTime =>
        positions[LabelLayoutElement.singleDate],
      LabelLayoutElement.singleModel =>
        positions[LabelLayoutElement.singleModelPort],
      LabelLayoutElement.singlePort => _followingTimePosition(
        positions[LabelLayoutElement.singleModelPort],
        0.30,
      ),
      LabelLayoutElement.singleModelPort =>
        positions[LabelLayoutElement.singleModel],
      LabelLayoutElement.dualDate => positions[LabelLayoutElement.dualDateTime],
      LabelLayoutElement.dualTime => _followingTimePosition(
        positions[LabelLayoutElement.dualDateTime],
        _dualTimeOffsetX,
      ),
      LabelLayoutElement.dualDateTime => positions[LabelLayoutElement.dualDate],
      _ => null,
    };
    if (legacyPosition != null) return legacyPosition;

    final defaults = LabelLayout.defaults().positions;
    return switch (element) {
      LabelLayoutElement.singleDateTime =>
        defaults[LabelLayoutElement.singleDate]!,
      LabelLayoutElement.dualDateTime => defaults[LabelLayoutElement.dualDate]!,
      _ => defaults[element]!,
    };
  }

  LabelLayout copyWithElement(
    LabelLayoutElement element,
    LabelLayoutPosition position,
  ) {
    return LabelLayout({...positions, element: position.clamp()});
  }

  String toEncodedJson() {
    final data = <String, Map<String, double>>{};
    for (final entry in positions.entries) {
      if (_isLegacyDateTimeElement(entry.key)) continue;
      data[entry.key.name] = entry.value.clamp().toJson();
    }

    // A layout assembled with the old public elements is upgraded as soon as
    // it is saved. Do not keep writing the legacy combined keys indefinitely.
    final legacySingle = positions[LabelLayoutElement.singleDateTime];
    if (legacySingle != null) {
      data.putIfAbsent(
        LabelLayoutElement.singleDate.name,
        () => legacySingle.clamp().toJson(),
      );
      data.putIfAbsent(
        LabelLayoutElement.singleTime.name,
        () =>
            _followingTimePosition(legacySingle, _singleTimeOffsetX)!.toJson(),
      );
    }
    final legacyDual = positions[LabelLayoutElement.dualDateTime];
    if (legacyDual != null) {
      data.putIfAbsent(
        LabelLayoutElement.dualDate.name,
        () => legacyDual.clamp().toJson(),
      );
      data.putIfAbsent(
        LabelLayoutElement.dualTime.name,
        () => _followingTimePosition(legacyDual, _dualTimeOffsetX)!.toJson(),
      );
    }
    return jsonEncode(data);
  }

  static LabelLayout fromEncodedJson(String? encoded) {
    if (encoded == null || encoded.isEmpty) return LabelLayout.defaults();
    final defaults = LabelLayout.defaults().positions;
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) return LabelLayout.defaults();
    final resolved = <LabelLayoutElement, LabelLayoutPosition>{...defaults};
    final explicitlyRestored = <LabelLayoutElement>{};
    LabelLayoutPosition? legacySingleDateTime;
    LabelLayoutPosition? legacyDualDateTime;
    LabelLayoutPosition? legacySingleModelPort;
    for (final entry in decoded.entries) {
      final element = LabelLayoutElement.values
          .where((candidate) => candidate.name == entry.key)
          .firstOrNull;
      if (element == null) continue;
      final position = LabelLayoutPosition.fromJson(entry.value);
      if (position == null) continue;
      switch (element) {
        case LabelLayoutElement.singleDateTime:
          legacySingleDateTime = position;
          break;
        case LabelLayoutElement.singleModelPort:
          legacySingleModelPort = position;
          break;
        case LabelLayoutElement.dualDateTime:
          legacyDualDateTime = position;
          break;
        default:
          resolved[element] = position;
          explicitlyRestored.add(element);
          break;
      }
    }

    if (legacySingleDateTime != null) {
      if (!explicitlyRestored.contains(LabelLayoutElement.singleDate)) {
        resolved[LabelLayoutElement.singleDate] = legacySingleDateTime;
      }
      if (!explicitlyRestored.contains(LabelLayoutElement.singleTime)) {
        resolved[LabelLayoutElement.singleTime] = _followingTimePosition(
          legacySingleDateTime,
          _singleTimeOffsetX,
        )!;
      }
    }
    if (legacyDualDateTime != null) {
      if (!explicitlyRestored.contains(LabelLayoutElement.dualDate)) {
        resolved[LabelLayoutElement.dualDate] = legacyDualDateTime;
      }
      if (!explicitlyRestored.contains(LabelLayoutElement.dualTime)) {
        resolved[LabelLayoutElement.dualTime] = _followingTimePosition(
          legacyDualDateTime,
          _dualTimeOffsetX,
        )!;
      }
    }
    if (legacySingleModelPort != null) {
      if (!explicitlyRestored.contains(LabelLayoutElement.singleModel)) {
        resolved[LabelLayoutElement.singleModel] = legacySingleModelPort;
      }
      if (!explicitlyRestored.contains(LabelLayoutElement.singlePort)) {
        resolved[LabelLayoutElement.singlePort] = _followingTimePosition(
          legacySingleModelPort,
          0.30,
        )!;
      }
    }
    return LabelLayout(resolved);
  }

  static bool _isLegacyDateTimeElement(LabelLayoutElement element) =>
      element == LabelLayoutElement.singleDateTime ||
      element == LabelLayoutElement.dualDateTime ||
      element == LabelLayoutElement.singleModelPort;

  static LabelLayoutPosition? _followingTimePosition(
    LabelLayoutPosition? datePosition,
    double horizontalOffset,
  ) {
    if (datePosition == null) return null;
    return LabelLayoutPosition(
      x: datePosition.x + horizontalOffset,
      y: datePosition.y,
      rotation: datePosition.rotation,
    ).clamp();
  }
}
