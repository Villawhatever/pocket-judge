import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/rule.dart';

class CoreRulesViewModel extends ChangeNotifier {
  CoreRulesViewModel() {
    _load();
  }

  final List<RuleModel> _rules = [];
  final Map<String, int> _reverseLookup = {};

  List<RuleModel> _filteredRules = [];

  List<RuleModel> get rules => _filteredRules;
  Map<String, int> get lookup => _reverseLookup;

  void search(String? search) {
    if (search == null || search.isEmpty) {
      _filteredRules = _rules;
      notifyListeners();
      return;
    }
    search = search.toLowerCase();
    _filteredRules = _rules
        .where((r) =>
          r.text.toLowerCase().contains(search!)
          || r.number.toLowerCase().contains(search))
        .toList();
    notifyListeners();
  }

  Future _load() async {
    final cr = await rootBundle.loadString('lib/assets/riftbound_core_rules.json');
    final data = jsonDecode(cr);

    var currentIndex = 0;

    for (final item in data) {
      final rule = RuleModel.fromJson(item);
      _reverseLookup[rule.number] = currentIndex++;
      _rules.add(rule);
    }

    _filteredRules = _rules;
    notifyListeners();
  }
}