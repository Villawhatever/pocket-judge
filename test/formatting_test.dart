import 'package:collection/collection.dart';
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
      {input: '[Assault]', expected: reddish},
      {input: '[Assault 2]', expected: reddish},
      {input: '[Accelerate]', expected: greenish},
      {input: '[Equip]', expected: grayish},
      {input: '[Deflect]', expected: yellowish},
    ];

    GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

    for (final data in testData) {
      testWidgets('Keyword formatting: ${data[input]}', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(PocketJudge(key: key));
        final result = formatCardText(
          data[input] as String,
          key.currentContext!,
        );
        final widget = result.first as WidgetSpan;
        final container = (widget.child as Transform).child as Container;
        container.should.haveColor(data[expected] as Color);
      });
    }

    final nestedTestData = [
      {input: '[Action]', expected: Transform},
      {input: '[Reaction][>]', expected: ClipPath},
      {input: ':rb_energy_1:', expected: SvgPicture},
    ];

    for (final data in nestedTestData) {
      testWidgets('Nested formatting: ${data[input]}', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(PocketJudge(key: key));
        final widgets = formatCardText(
          '(This is reminder text with ${data[input] as String} in it.)',
          key.currentContext!,
        );
        var bodyStyle = key.currentContext!.textTheme.bodySmall!;

        (widgets.first as TextSpan).should.haveFontStyle(FontStyle.italic);
        (widgets.first as TextSpan).should.haveColor(bodyStyle.color!);
        final type = data[expected] as Type;

        final widgetSpan =
            widgets.firstWhereOrNull((w) => w.runtimeType == WidgetSpan)
                as WidgetSpan?;
        if (widgetSpan != null) {
          widgetSpan.child.runtimeType.should.be(type);
        } else {
          widgets
              .firstWhereOrNull((w) => w.runtimeType == type)
              .should
              .not
              .beNull();
        }
        //find.byType(data[expected] as Type).should.not.beNull();
      });
    }
  });
}
