import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core_rules/rule.dart';

class TournamentRulesViewModel extends ChangeNotifier {
  TournamentRulesViewModel() {
    _load();
  }

  final List<RuleModel> _rules = [];
  final Map<String, int> _reverseLookup = {};

  List<RuleModel> _filteredRules = [];

  List<RuleModel> get rules => _filteredRules;
  bool get isFiltered => _rules.length != _filteredRules.length;
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
            r.text.toLowerCase().contains(search!) ||
            r.number.toLowerCase().contains(search))
        .toList();
    notifyListeners();
  }

  Future _load() async {
    final data = await FirebaseFirestore.instance.collection('tournament_rules').get();
    var currentIndex = 0;

    for (final item in data.docs) {
      final rule = RuleModel.fromJson(item.data());
      _reverseLookup[rule.number] = currentIndex++;
      _rules.add(rule);
    }

    _filteredRules = _rules;
    notifyListeners();
  }
}
