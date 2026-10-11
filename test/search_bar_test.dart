import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_judge/widgets/search_bar.dart';

import 'extensions.dart';

void main() {
  final testData = {
    {input: 'whatever text', expected: true},
    {input: '', expected: false},
  };

  for (final data in testData) {
    testWidgets('Search icon visible: ${data[expected]}', (
      WidgetTester tester,
    ) async {
      final textCtrl = TextEditingController();
      textCtrl.text = data[input] as String;

      await tester.pumpWidget(
        MaterialApp(home: CustomSearchBar(textController: textCtrl)),
      );

      expect(
        find.widgetWithImage(
          IconButton,
          AssetImage('lib/assets/img/search.png'),
        ),
        (data[expected] as bool) ? findsNothing : findsOneWidget,
      );
      expect(
        find.byIcon(Icons.clear),
        (data[expected] as bool) ? findsOneWidget : findsNothing,
      );
    });
  }
}
