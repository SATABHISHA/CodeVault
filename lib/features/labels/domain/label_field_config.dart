import 'dart:convert';

enum LabelFieldKey {
  companyName,
  companyAddress,
  partNumber,
  itemName,
  model,
  port,

  /// Retained so layouts saved before date and time were separated still load.
  dateTime,
  date,
  time,
  codeData,
  barcode,
  serialNumber,
}

enum LabelFontStyle { normal, italic }

enum LabelFontWeight { regular, medium, semiBold, bold, black }

class LabelFieldSetting {
  const LabelFieldSetting({
    required this.visible,
    required this.fontSize,
    this.showCaption = true,
    this.fontStyle = LabelFontStyle.normal,
    this.fontWeight = LabelFontWeight.bold,
  });

  final bool visible;
  final double fontSize;
  final bool showCaption;
  final LabelFontStyle fontStyle;
  final LabelFontWeight fontWeight;

  LabelFieldSetting copyWith({
    bool? visible,
    double? fontSize,
    bool? showCaption,
    LabelFontStyle? fontStyle,
    LabelFontWeight? fontWeight,
  }) {
    return LabelFieldSetting(
      visible: visible ?? this.visible,
      fontSize: (fontSize ?? this.fontSize).clamp(
        LabelFieldConfig.minFontSize,
        LabelFieldConfig.maxFontSize,
      ),
      showCaption: showCaption ?? this.showCaption,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  Map<String, dynamic> toJson() => {
    'visible': visible,
    'font_size': fontSize,
    'show_caption': showCaption,
    'font_style': fontStyle.name,
    'font_weight': fontWeight.name,
  };

  static LabelFieldSetting? fromJson(
    Object? value, {
    bool defaultShowCaption = true,
    LabelFontStyle defaultFontStyle = LabelFontStyle.normal,
    LabelFontWeight defaultFontWeight = LabelFontWeight.bold,
  }) {
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
      showCaption: value['show_caption'] is bool
          ? value['show_caption'] as bool
          : defaultShowCaption,
      fontStyle: _enumByName(
        LabelFontStyle.values,
        value['font_style'],
        defaultFontStyle,
      ),
      fontWeight: _enumByName(
        LabelFontWeight.values,
        value['font_weight'],
        defaultFontWeight,
      ),
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    Object? name,
    T fallback,
  ) {
    if (name is! String) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}

class LabelFieldConfig {
  const LabelFieldConfig._();

  static const double minFontSize = 7.0;
  static const double maxFontSize = 60.0;

  static const Map<LabelFieldKey, LabelFieldSetting> _defaults = {
    // Caption defaults mirror the legacy preview so existing Part Masters do
    // not suddenly gain prefixes after upgrading. Users can opt in per field.
    LabelFieldKey.companyName: LabelFieldSetting(
      visible: true,
      fontSize: 14,
      showCaption: false,
      fontWeight: LabelFontWeight.black,
    ),
    LabelFieldKey.companyAddress: LabelFieldSetting(
      visible: true,
      fontSize: 9,
      showCaption: false,
      fontWeight: LabelFontWeight.regular,
    ),
    LabelFieldKey.partNumber: LabelFieldSetting(visible: true, fontSize: 12),
    LabelFieldKey.itemName: LabelFieldSetting(
      visible: true,
      fontSize: 10,
      showCaption: false,
    ),
    LabelFieldKey.model: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.port: LabelFieldSetting(
      visible: true,
      fontSize: 10,
      showCaption: false,
    ),
    LabelFieldKey.dateTime: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.date: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.time: LabelFieldSetting(visible: true, fontSize: 10),
    LabelFieldKey.codeData: LabelFieldSetting(
      visible: true,
      fontSize: 10,
      showCaption: false,
    ),
    LabelFieldKey.barcode: LabelFieldSetting(
      visible: true,
      fontSize: 10,
      showCaption: false,
    ),
    LabelFieldKey.serialNumber: LabelFieldSetting(visible: true, fontSize: 10),
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
    final parsedKeys = <LabelFieldKey>{};
    for (final entry in value.entries) {
      final key = LabelFieldKey.values
          .where((candidate) => candidate.name == entry.key)
          .firstOrNull;
      if (key == null) continue;
      final parsed = LabelFieldSetting.fromJson(
        entry.value,
        defaultShowCaption: _defaults[key]?.showCaption ?? true,
        defaultFontStyle: _defaults[key]?.fontStyle ?? LabelFontStyle.normal,
        defaultFontWeight: _defaults[key]?.fontWeight ?? LabelFontWeight.bold,
      );
      if (parsed != null) {
        resolved[key] = parsed;
        parsedKeys.add(key);
      }
    }
    final legacyDateTime = parsedKeys.contains(LabelFieldKey.dateTime)
        ? resolved[LabelFieldKey.dateTime]
        : null;
    if (legacyDateTime != null) {
      if (!parsedKeys.contains(LabelFieldKey.date)) {
        resolved[LabelFieldKey.date] = legacyDateTime;
      }
      if (!parsedKeys.contains(LabelFieldKey.time)) {
        resolved[LabelFieldKey.time] = legacyDateTime;
      }
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
    final legacyDateTime = settings[LabelFieldKey.dateTime];
    if (legacyDateTime != null) {
      if (!settings.containsKey(LabelFieldKey.date)) {
        merged[LabelFieldKey.date] = legacyDateTime;
      }
      if (!settings.containsKey(LabelFieldKey.time)) {
        merged[LabelFieldKey.time] = legacyDateTime;
      }
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
