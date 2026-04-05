import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_judge/widgets/search.dart';

void main() {
  testWidgets('Renders Clear icon when no text', (WidgetTester tester) async {
    final textCtrl = TextEditingController();

    await tester.pumpWidget(
        MaterialApp(home: CustomSearchBar(textController: textCtrl)));

    expect(
        find.widgetWithImage(
            IconButton, AssetImage('lib/assets/img/search.png')),
        findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('Renders custom search when text', (WidgetTester tester) async {
    final textCtrl = TextEditingController();
    textCtrl.text = "blah";
    await tester.pumpWidget(
        MaterialApp(home: CustomSearchBar(textController: textCtrl)));
    expect(
        find.widgetWithImage(
            IconButton, AssetImage('lib/assets/img/search.png')),
        findsNothing);
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });
}
