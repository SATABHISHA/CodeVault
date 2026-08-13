const double minLabelCodeScale = 0.25;
const double maxLabelCodeScale = 2.0;
const double defaultLabelCodeScale = 1.0;

/// Normalizes a persisted barcode/QR/Data Matrix dimension scale.
///
/// Numeric strings are accepted for compatibility with APIs that serialize
/// decimal columns as strings. Existing records without these fields retain
/// the original code size through the [defaultLabelCodeScale] fallback.
double normalizeLabelCodeScale(Object? value) {
  final parsed = switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text.trim()),
    _ => null,
  };
  if (parsed == null || !parsed.isFinite) return defaultLabelCodeScale;
  return parsed.clamp(minLabelCodeScale, maxLabelCodeScale).toDouble();
}
