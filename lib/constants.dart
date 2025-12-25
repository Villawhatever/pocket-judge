import 'package:flutter/cupertino.dart';

class PreferencesKeys extends InheritedWidget {
  static PreferencesKeys? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PreferencesKeys>();

  const PreferencesKeys({required Widget child, required Key key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(PreferencesKeys oldWidget) => false;
}
