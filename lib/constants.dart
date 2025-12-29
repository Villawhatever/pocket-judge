import 'package:flutter/cupertino.dart';

class PreferencesKeys extends InheritedWidget {
  static PreferencesKeys? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PreferencesKeys>();

  const PreferencesKeys({required super.child, required Key super.key});

  @override
  bool updateShouldNotify(PreferencesKeys oldWidget) => false;
}
