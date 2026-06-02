import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pocket_judge/constants.dart';
import 'package:pocket_judge/main.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';
import 'package:pocket_judge/utils/formatting.dart';
import 'package:shouldly/shouldly.dart';

import 'extensions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  doSetup();

  group('Card text formatting', () {
    final testData = [
      {'input': 'Assault', 'expectedColor': reddish},
      {'input': 'Assault 2', 'expectedColor': reddish},
      {'input': 'Accelerate', 'expectedColor': greenish},
      {'input': 'Equip', 'expectedColor': grayish},
      {'input': 'Deflect', 'expectedColor': yellowish},
    ];

    GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

    for (final data in testData) {
      testWidgets('Keyword formatting: ${data['input']}',
          (WidgetTester tester) async {
        await tester.pumpWidget(PocketJudge(key: key));
        final result =
            formatCardText(data['input'] as String, key.currentContext!);
        final widget = result.first as TextSpan;
        widget.should.haveColor(data['expectedColor'] as Color);
        widget.should.haveFontWeight(FontWeight.bold);
      });
    }

    testWidgets('Nested formatting works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(PocketJudge(key: key));
      final widgets = formatCardText(
          '(This is reminder text with a :rb_energy_1: rune in it)',
          key.currentContext!);
      var bodyStyle = key.currentContext!.textTheme.bodySmall!;
      widgets.length.should.be(3);
      (widgets.first as TextSpan).should.haveFontStyle(FontStyle.italic);
      (widgets.first as TextSpan).should.haveColor(bodyStyle.color!);

      (widgets.last as TextSpan).should.haveColor(bodyStyle.color!);
      (widgets.last as TextSpan).should.haveFontStyle(FontStyle.italic);

      find
          .byWidget(SvgPicture.asset('lib/assets/img/energy_1.svg'))
          .should
          .not
          .beNull();
    });
  });
}
