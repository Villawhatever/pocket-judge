import 'package:flutter/cupertino.dart';

class Fonts {
  static const String spiegel = 'Spiegel';
  static const String beaufort = 'Beaufort';
}

class PreferencesKeys extends InheritedWidget {
  static PreferencesKeys? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PreferencesKeys>();

  const PreferencesKeys({required super.child, required Key super.key});

  @override
  bool updateShouldNotify(PreferencesKeys oldWidget) => false;
}
