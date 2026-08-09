import 'dart:convert';

import 'label_field_config.dart';

class DynamicLabelField {
  const DynamicLabelField({
    required this.id,
    required this.label,
    required this.value,
    this.visible = true,
    this.fontSize = 10,
    this.x = .24,
    this.y = .74,
    this.rotation = 0,
  });

  final String id;
  final String label;
  final String value;
  final bool visible;
  final double fontSize;
  final double x;
  final double y;
  final double rotation;

  DynamicLabelField copyWith({
    String? label,
    String? value,
    bool? visible,
    double? fontSize,
    double? x,
    double? y,
    double? rotation,
  }) => DynamicLabelField(
    id: id,
    label: label ?? this.label,
    value: value ?? this.value,
    visible: visible ?? this.visible,
    fontSize: (fontSize ?? this.fontSize).clamp(
      LabelFieldConfig.minFontSize,
      LabelFieldConfig.maxFontSize,
    ),
    x: (x ?? this.x).clamp(-20.0, 20.0),
    y: (y ?? this.y).clamp(-20.0, 20.0),
    rotation: (rotation ?? this.rotation).isFinite
        ? (rotation ?? this.rotation)
        : 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value': value,
    'visible': visible,
    'font_size': fontSize,
    'x': x,
    'y': y,
    'rotation': rotation,
  };

  static DynamicLabelField? fromJson(Object? raw, {int index = 0}) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final id = json['id'];
    final label = json['label'];
    final value = json['value'];
    if (id is! String || label is! String || value is! String) return null;
    final size = json['font_size'];
    final x = json['x'];
    final y = json['y'];
    final rotation = json['rotation'];
    return DynamicLabelField(
      id: id,
      label: label,
      value: value,
      visible: json['visible'] is bool ? json['visible'] as bool : true,
      fontSize: (size is num ? size.toDouble() : 10.0)
          .clamp(LabelFieldConfig.minFontSize, LabelFieldConfig.maxFontSize)
          .toDouble(),
      x: (x is num ? x.toDouble() : .24).clamp(-20.0, 20.0).toDouble(),
      y: (y is num ? y.toDouble() : .74 + (index * .075))
          .clamp(-20.0, 20.0)
          .toDouble(),
      rotation: rotation is num ? rotation.toDouble() : 0,
    );
  }

  static List<DynamicLabelField> listFromDynamic(Object? raw) {
    Object? decoded = raw;
    if (raw is String && raw.isNotEmpty) {
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        return const [];
      }
    }
    if (decoded is! List) return const [];
    return decoded.indexed
        .map((entry) => fromJson(entry.$2, index: entry.$1))
        .whereType<DynamicLabelField>()
        .toList();
  }

  static List<Map<String, dynamic>> listToJson(
    Iterable<DynamicLabelField> fields,
  ) => fields.map((field) => field.toJson()).toList();
}
