import 'dart:convert';

import 'package:codevault/features/labels/domain/label_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default layouts expose independently positioned Date and Time', () {
    final layout = LabelLayout.defaults();

    expect(layout.positions, contains(LabelLayoutElement.singleDate));
    expect(layout.positions, contains(LabelLayoutElement.singleTime));
    expect(layout.positions, contains(LabelLayoutElement.dualDate));
    expect(layout.positions, contains(LabelLayoutElement.dualTime));
    expect(
      layout.positions,
      isNot(contains(LabelLayoutElement.singleDateTime)),
    );
    expect(layout.positions, isNot(contains(LabelLayoutElement.dualDateTime)));
    expect(
      layout.positionFor(LabelLayoutElement.singleDate).x,
      isNot(layout.positionFor(LabelLayoutElement.singleTime).x),
    );
    expect(
      layout.positionFor(LabelLayoutElement.dualDate).x,
      isNot(layout.positionFor(LabelLayoutElement.dualTime).x),
    );
  });

  test('legacy combined positions migrate to independent Date and Time', () {
    final migrated = LabelLayout.fromEncodedJson(
      jsonEncode({
        'singleDateTime': {'x': .31, 'y': .42, 'rotation': .7},
        'dualDateTime': {'x': .18, 'y': .63, 'rotation': -.4},
      }),
    );

    expect(migrated.positionFor(LabelLayoutElement.singleDate).toJson(), {
      'x': .31,
      'y': .42,
      'rotation': .7,
    });
    expect(migrated.positionFor(LabelLayoutElement.singleTime).toJson(), {
      'x': .55,
      'y': .42,
      'rotation': .7,
    });
    expect(migrated.positionFor(LabelLayoutElement.dualDate).toJson(), {
      'x': .18,
      'y': .63,
      'rotation': -.4,
    });
    expect(migrated.positionFor(LabelLayoutElement.dualTime).toJson(), {
      'x': .37,
      'y': .63,
      'rotation': -.4,
    });

    final saved = jsonDecode(migrated.toEncodedJson()) as Map<String, dynamic>;
    expect(saved, isNot(contains('singleDateTime')));
    expect(saved, isNot(contains('dualDateTime')));
    expect(saved, contains('singleDate'));
    expect(saved, contains('singleTime'));
    expect(saved, contains('dualDate'));
    expect(saved, contains('dualTime'));
  });

  test('explicit independent positions take precedence over legacy values', () {
    final migrated = LabelLayout.fromEncodedJson(
      jsonEncode({
        'singleDateTime': {'x': .1, 'y': .2, 'rotation': .3},
        'singleDate': {'x': .8, 'y': .7, 'rotation': .6},
        'dualDateTime': {'x': .2, 'y': .3, 'rotation': .4},
        'dualTime': {'x': .9, 'y': .8, 'rotation': .7},
      }),
    );

    expect(migrated.positionFor(LabelLayoutElement.singleDate).toJson(), {
      'x': .8,
      'y': .7,
      'rotation': .6,
    });
    final singleTime = migrated.positionFor(LabelLayoutElement.singleTime);
    expect(singleTime.x, closeTo(.34, 0.0000001));
    expect(singleTime.y, .2);
    expect(singleTime.rotation, .3);
    expect(migrated.positionFor(LabelLayoutElement.dualDate).toJson(), {
      'x': .2,
      'y': .3,
      'rotation': .4,
    });
    expect(migrated.positionFor(LabelLayoutElement.dualTime).toJson(), {
      'x': .9,
      'y': .8,
      'rotation': .7,
    });
  });

  test('layouts built with legacy elements upgrade when encoded', () {
    const legacyPosition = LabelLayoutPosition(x: .4, y: .5, rotation: .6);
    const layout = LabelLayout({
      LabelLayoutElement.singleDateTime: legacyPosition,
    });

    expect(
      layout.positionFor(LabelLayoutElement.singleDate),
      same(legacyPosition),
    );
    expect(layout.positionFor(LabelLayoutElement.singleTime).x, .64);

    final saved = jsonDecode(layout.toEncodedJson()) as Map<String, dynamic>;
    expect(saved, isNot(contains('singleDateTime')));
    expect(saved['singleDate'], legacyPosition.toJson());
    expect(saved['singleTime'], {'x': .64, 'y': .5, 'rotation': .6});
  });
}
