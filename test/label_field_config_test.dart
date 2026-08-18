import 'package:codevault/features/labels/domain/dynamic_label_field.dart';
import 'package:codevault/features/labels/domain/label_field_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deep black weights survive field configuration persistence', () {
    for (final weight in [
      LabelFontWeight.extraBold,
      LabelFontWeight.extraBlack,
      LabelFontWeight.ultraBlack,
    ]) {
      final original = LabelFieldConfig.defaults();
      original[LabelFieldKey.model] = original[LabelFieldKey.model]!.copyWith(
        fontSize: 24,
        fontWeight: weight,
      );
      final restored = LabelFieldConfig.fromEncodedJson(
        LabelFieldConfig.toEncodedJson(original),
      );
      expect(restored[LabelFieldKey.model]!.fontSize, 24);
      expect(restored[LabelFieldKey.model]!.fontWeight, weight);
    }
  });

  test('caption defaults preserve the legacy label appearance', () {
    final settings = LabelFieldConfig.defaults();

    for (final key in [
      LabelFieldKey.companyName,
      LabelFieldKey.companyAddress,
      LabelFieldKey.itemName,
      LabelFieldKey.port,
      LabelFieldKey.codeData,
    ]) {
      expect(settings[key]!.showCaption, isFalse);
    }
    for (final key in [
      LabelFieldKey.partNumber,
      LabelFieldKey.serialNumber,
      LabelFieldKey.model,
      LabelFieldKey.date,
      LabelFieldKey.time,
    ]) {
      expect(settings[key]!.showCaption, isTrue);
    }
    expect(
      settings[LabelFieldKey.companyName]!.fontWeight,
      LabelFontWeight.black,
    );
    expect(
      settings[LabelFieldKey.companyAddress]!.fontWeight,
      LabelFontWeight.regular,
    );
  });

  test('legacy field settings retain captions and seed date and time', () {
    final settings = LabelFieldConfig.fromJsonObject({
      'dateTime': {'visible': false, 'font_size': 18},
    });

    for (final key in [LabelFieldKey.date, LabelFieldKey.time]) {
      expect(settings[key]!.visible, isFalse);
      expect(settings[key]!.fontSize, 18);
      expect(settings[key]!.showCaption, isTrue);
      expect(settings[key]!.fontStyle, LabelFontStyle.normal);
      expect(settings[key]!.fontWeight, LabelFontWeight.bold);
    }
  });

  test('explicit date or time settings override legacy date-time settings', () {
    final settings = LabelFieldConfig.fromJsonObject({
      'dateTime': {'visible': false, 'font_size': 18},
      'date': {
        'visible': true,
        'font_size': 21,
        'show_caption': false,
        'font_style': 'italic',
        'font_weight': 'medium',
      },
    });

    expect(settings[LabelFieldKey.date]!.visible, isTrue);
    expect(settings[LabelFieldKey.date]!.fontSize, 21);
    expect(settings[LabelFieldKey.date]!.showCaption, isFalse);
    expect(settings[LabelFieldKey.date]!.fontStyle, LabelFontStyle.italic);
    expect(settings[LabelFieldKey.date]!.fontWeight, LabelFontWeight.medium);
    expect(settings[LabelFieldKey.time]!.visible, isFalse);
    expect(settings[LabelFieldKey.time]!.fontSize, 18);
  });

  test('field typography round-trips and clamps at 60 points', () {
    const customized = LabelFieldSetting(
      visible: true,
      fontSize: 60,
      showCaption: false,
      fontStyle: LabelFontStyle.italic,
      fontWeight: LabelFontWeight.black,
    );
    final restored = LabelFieldSetting.fromJson(customized.toJson())!;

    expect(restored.showCaption, isFalse);
    expect(restored.fontStyle, LabelFontStyle.italic);
    expect(restored.fontWeight, LabelFontWeight.black);
    expect(restored.copyWith(fontSize: 80).fontSize, 60);
  });

  test('dynamic field caption and typography remain backup compatible', () {
    const field = DynamicLabelField(
      id: 'batch',
      label: 'Batch',
      value: '2608',
      fontSize: 60,
      showCaption: false,
      fontStyle: LabelFontStyle.italic,
      fontWeight: LabelFontWeight.semiBold,
    );
    final restored = DynamicLabelField.fromJson(field.toJson())!;

    expect(restored.showCaption, isFalse);
    expect(restored.fontStyle, LabelFontStyle.italic);
    expect(restored.fontWeight, LabelFontWeight.semiBold);
    expect(restored.fontSize, 60);

    final legacy = DynamicLabelField.fromJson({
      'id': 'legacy',
      'label': 'Legacy',
      'value': 'value',
      'font_size': 10,
    })!;
    expect(legacy.showCaption, isTrue);
    expect(legacy.fontStyle, LabelFontStyle.normal);
    expect(legacy.fontWeight, LabelFontWeight.bold);
  });
}
