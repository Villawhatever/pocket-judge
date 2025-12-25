import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState with ChangeNotifier {
  late SharedPreferences? _preferences;
  late bool _isAnnotationsEnabled = false;

  PreferencesState() {
    init();
  }

  void init() async => _preferences = await SharedPreferences.getInstance();

  bool get isAnnotationsEnabled => _isAnnotationsEnabled;

  Future setIsAnnotationsEnabled(bool isEnabled) async {
    _isAnnotationsEnabled = isEnabled;
    _preferences?.setBool(Keys.annotations, isEnabled);
    notifyListeners();
  }
}

class Keys {
  static const annotations = "Annotations";
}
