import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/sorts.dart';
import 'rule.dart';

class CoreRulesViewModel extends ChangeNotifier {
  final List<RuleModel> _rules = [];
  final Map<String, int> _reverseLookup = {};

  List<RuleModel> _filteredRules = [];

  List<RuleModel> get rules => _filteredRules;
  bool get isFiltered => _rules.length != _filteredRules.length;
  Map<String, int> get lookup => _reverseLookup;

  void reset() {
    _filteredRules = _rules;
  }

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

  Future load() async {
    if (_rules.isNotEmpty) {
      return;
    }

    final data =
        await FirebaseFirestore.instance.collection('core_rules').get();

    for (final item in data.docs) {
      final rule = RuleModel.fromJson(item.data());
      _rules.add(rule);
    }

    _rules.sort((a, b) => sortRules(a.number, b.number));

    for (var i = 0; i < _rules.length; i++) {
      _reverseLookup[_rules[i].number] = i;
    }

    _filteredRules = _rules;
    notifyListeners();
  }
}
