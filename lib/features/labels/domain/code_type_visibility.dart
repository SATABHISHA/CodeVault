abstract final class CodeTypeVisibility {
  static const all = <String>{'code128', 'qr', 'data_matrix'};
  static const ordered = <String>['code128', 'qr', 'data_matrix'];

  static const labels = <String, String>{
    'code128': 'Code 128',
    'qr': 'QR code',
    'data_matrix': 'Data Matrix',
  };

  static Set<String> sanitize(Iterable<String> values) {
    final result = values.where(all.contains).toSet();
    return result.isEmpty ? Set.of(all) : result;
  }
}
