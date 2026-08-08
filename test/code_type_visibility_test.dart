import 'package:codevault/features/labels/domain/code_type_visibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'code type visibility removes unknown values and keeps a safe default',
    () {
      expect(CodeTypeVisibility.sanitize(['qr', 'unknown']), equals({'qr'}));
      expect(
        CodeTypeVisibility.sanitize(const []),
        equals(CodeTypeVisibility.all),
      );
    },
  );
}
