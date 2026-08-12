import 'dart:convert';
import 'dart:typed_data';

import 'package:codevault/features/btw/domain/btw_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const importer = BtwImporter();

  test('imports named JSON values as editable BTW fields', () {
    final result = importer.parse(
      Uint8List.fromList(
        utf8.encode(
          '{"part_number":"P-42","item_name":"Motor",'
          '"model":"MX","serial_number":"007","voltage":"24V"}',
        ),
      ),
      filename: 'motor.btw',
    );

    expect(result.partNumber, 'P-42');
    expect(result.itemName, 'Motor');
    expect(result.model, 'MX');
    expect(result.serialNumber, '007');
    expect(result.fields.single.label, 'Voltage');
    expect(result.fields.single.value, '24V');
  });

  test('imports XML named data sources', () {
    final result = importer.parse(
      Uint8List.fromList(
        utf8.encode(
          '<field name="Part No" value="A100"/>'
          '<field name="Temperature" value="80 C"/>',
        ),
      ),
      filename: 'thermal.btw',
    );

    expect(result.partNumber, 'A100');
    expect(result.fields.single.label, 'Temperature');
    expect(result.fields.single.value, '80 C');
  });

  test('rejects files without discoverable editable values', () {
    expect(
      () => importer.parse(Uint8List.fromList([1, 2, 3]), filename: 'bad.btw'),
      throwsFormatException,
    );
  });
}
