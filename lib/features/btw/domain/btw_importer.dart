import 'dart:convert';
import 'dart:typed_data';

import '../../labels/domain/dynamic_label_field.dart';

class BtwImportResult {
  const BtwImportResult({
    required this.partNumber,
    required this.itemName,
    required this.model,
    required this.serialNumber,
    required this.fields,
    required this.warnings,
  });

  final String partNumber;
  final String itemName;
  final String model;
  final String serialNumber;
  final List<DynamicLabelField> fields;
  final List<String> warnings;
}

/// Best-effort metadata importer for BarTender documents.
///
/// BarTender's native BTW container is proprietary and its internal format can
/// vary by BarTender version. CodeVault never pretends that it can reproduce
/// an opaque document pixel-for-pixel. It imports structured JSON/XML exports,
/// named substitutions, and readable strings from native containers, then
/// exposes the result as ordinary editable label fields.
class BtwImporter {
  const BtwImporter();

  BtwImportResult parse(Uint8List bytes, {required String filename}) {
    if (bytes.isEmpty) throw const FormatException('The BTW file is empty.');
    final strings = <String>[];
    final utf8Text = utf8.decode(bytes, allowMalformed: true);
    strings.addAll(_readStructuredText(utf8Text));
    strings.addAll(_readUtf16Strings(bytes));

    final values = <String, String>{};
    for (final value in strings) {
      final cleaned = value.replaceAll(RegExp(r'[\x00-\x1F]'), ' ').trim();
      if (cleaned.length < 2 || cleaned.length > 160) continue;
      final pair = RegExp(
        r'^\s*([A-Za-z][A-Za-z0-9 _./#-]{1,40})\s*[:=]\s*(.{1,100})\s*$',
      ).firstMatch(cleaned);
      if (pair != null) {
        values.putIfAbsent(
          _normalise(pair.group(1)!),
          () => pair.group(2)!.trim(),
        );
      }
    }

    final basename = filename.replaceFirst(
      RegExp(r'\.btw$', caseSensitive: false),
      '',
    );
    String take(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final found = values.remove(key);
        if (found != null && found.isNotEmpty) return found;
      }
      return fallback;
    }

    final part = take(const ['part number', 'part no', 'part', 'partnumber']);
    final item = take(const [
      'item name',
      'item',
      'product name',
      'product',
    ], basename.isEmpty ? 'Imported BTW label' : basename);
    final model = take(const ['model', 'model number', 'model no']);
    final serial = take(const ['serial number', 'serial no', 'serial']);
    final fields = <DynamicLabelField>[];
    var index = 0;
    for (final entry in values.entries) {
      if (_ignoredKey(entry.key) || entry.value.trim().isEmpty) continue;
      fields.add(
        DynamicLabelField(
          id: 'btw-${index++}-${entry.key.hashCode.abs()}',
          label: _title(entry.key),
          value: entry.value,
          x: .28,
          y: (.70 + (index * .06)).clamp(0.0, .94),
        ),
      );
      if (fields.length == 24) break;
    }

    if (part.isEmpty && fields.isEmpty && model.isEmpty && serial.isEmpty) {
      throw const FormatException(
        'No editable fields were found. Export the BarTender document as XML/JSON or add named data sources before importing.',
      );
    }
    return BtwImportResult(
      partNumber: part.isEmpty ? basename : part,
      itemName: item,
      model: model,
      serialNumber: serial,
      fields: fields,
      warnings:
          utf8Text.trimLeft().startsWith('<') ||
              utf8Text.trimLeft().startsWith('{')
          ? const []
          : const [
              'Native BTW content was imported from readable named values. Review the preview before printing.',
            ],
    );
  }

  Iterable<String> _readStructuredText(String text) sync* {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(text);
        yield* _flattenJson(decoded);
      } on FormatException {
        // Continue with text extraction.
      }
    }
    for (final match in RegExp(
      r'''(?:name|field|id)\s*=\s*["']([^"']+)["'][^>]*?(?:value\s*=\s*["']([^"']*)["']|>([^<]+)<)''',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(text)) {
      yield '${match.group(1)}: ${match.group(2) ?? match.group(3) ?? ''}';
    }
    yield* text.split(RegExp(r'[\r\n]+'));
  }

  Iterable<String> _flattenJson(Object? value, [String prefix = '']) sync* {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = prefix.isEmpty ? '${entry.key}' : '$prefix ${entry.key}';
        yield* _flattenJson(entry.value, key);
      }
    } else if (value is List) {
      for (final item in value) {
        yield* _flattenJson(item, prefix);
      }
    } else if (value != null && prefix.isNotEmpty) {
      yield '$prefix: $value';
    }
  }

  Iterable<String> _readUtf16Strings(Uint8List bytes) sync* {
    final buffer = StringBuffer();
    for (var index = 0; index + 1 < bytes.length; index += 2) {
      final code = bytes[index] | (bytes[index + 1] << 8);
      if (code >= 32 && code <= 126) {
        buffer.writeCharCode(code);
      } else {
        if (buffer.length >= 4) yield buffer.toString();
        buffer.clear();
      }
    }
    if (buffer.length >= 4) yield buffer.toString();
  }

  String _normalise(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[_./#-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _title(String value) => value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  bool _ignoredKey(String key) => const {
    'version',
    'format',
    'printer',
    'document',
    'template',
    'filename',
  }.contains(key);
}
