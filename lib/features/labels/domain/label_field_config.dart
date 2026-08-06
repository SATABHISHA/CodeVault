import 'dart:convert';

enum LabelFieldKey {
  companyName,
  companyAddress,
  partNumber,
  itemName,
  model,
  port,
  dateTime,
  codeData,
  barcode,
}

class LabelFieldSetting {
  const LabelFieldSetting({required this.visible, required this.fontSize});

  final bool visible;
  final double fontSize;

  LabelFieldSetting copyWith({bool? visible, double? fontSize}) {
    return LabelFieldSetting(
      visible: visible ?? this.visible,
      fontSize: (fontSize ?? this.fontSize).clamp(
        LabelFieldConfig.minFontSize,
        LabelFieldConfig.maxFontSize,
      ),
    );
  }

  Map<String, dynamic> toJson() => {'visible': visible, 'font_size': fontSize};

  static LabelFieldSetting? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final visible = value['visible'];
    final fontSize = value['font_size'];
    if (visible is! bool || fontSize is! num) return null;
    return LabelFieldSetting(
      visible: visible,
      fontSize: fontSize.toDouble().clamp(
        LabelFieldConfig.minFontSize,
        LabelFieldConfig.maxFontSize,
      ),
    );
  }
}

class LabelFieldConfig {
  const LabelFieldConfig._();

  static const double minFontSize = 7.0;
  static const double maxFontSize = 24.0;

  static const Map<LabelFieldKey, LabelFieldSetting> _defaults = {
    LabelFieldKey.companyName: LabelFieldSetting(visible: true, fontSize: 14),
    LabelFieldKey.companyAddress: LabelFieldSetting(visible: true, fontSize: 9),
    LabelFieldKey.partNumber: LabelFieldSetting(visible: true, fontSize: 12),
    LabelFieldKey.itemName: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.model: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.port: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.dateTime: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.codeData: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.barcode: LabelFieldSetting(visible: true, fontSize: 10),
  };

  static Map<LabelFieldKey, LabelFieldSetting> defaults() => {
    for (final entry in _defaults.entries) entry.key: entry.value,
  };

  static Map<String, dynamic> toJsonObject(
    Map<LabelFieldKey, LabelFieldSetting> settings,
  ) {
    final merged = mergeWithDefaults(settings);
    return {
      for (final entry in merged.entries) entry.key.name: entry.value.toJson(),
    };
  }

  static String toEncodedJson(Map<LabelFieldKey, LabelFieldSetting> settings) =>
      jsonEncode(toJsonObject(settings));

  static Map<LabelFieldKey, LabelFieldSetting> fromEncodedJson(
    String? encoded,
  ) {
    if (encoded == null || encoded.isEmpty) return defaults();
    final decoded = jsonDecode(encoded);
    return fromJsonObject(decoded);
  }

  static Map<LabelFieldKey, LabelFieldSetting> fromJsonObject(Object? value) {
    final resolved = defaults();
    if (value is! Map<String, dynamic>) return resolved;
    for (final entry in value.entries) {
      final key = LabelFieldKey.values
          .where((candidate) => candidate.name == entry.key)
          .firstOrNull;
      if (key == null) continue;
      final parsed = LabelFieldSetting.fromJson(entry.value);
      if (parsed != null) resolved[key] = parsed;
    }
    return resolved;
  }

  static Map<LabelFieldKey, LabelFieldSetting> fromDynamic(Object? value) {
    if (value is String) return fromEncodedJson(value);
    return fromJsonObject(value);
  }

  static Map<LabelFieldKey, LabelFieldSetting> mergeWithDefaults(
    Map<LabelFieldKey, LabelFieldSetting>? settings,
  ) {
    final merged = defaults();
    if (settings == null) return merged;
    for (final entry in settings.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }

  static bool isVisible(
    LabelFieldKey key,
    Map<LabelFieldKey, LabelFieldSetting>? settings,
  ) => mergeWithDefaults(settings)[key]!.visible;

  static double fontSizeFor(
    LabelFieldKey key,
    Map<LabelFieldKey, LabelFieldSetting>? settings,
  ) => mergeWithDefaults(settings)[key]!.fontSize;
}
