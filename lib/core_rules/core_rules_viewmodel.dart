import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocket_judge/extensions/list_extensions.dart';
import 'rule.dart';

class CoreRulesViewModel extends ChangeNotifier {
  CoreRulesViewModel() {
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
    final data =
        await FirebaseFirestore.instance.collection('core_rules').get();
    var currentIndex = 0;

    for (final item in data.docs) {
      final rule = RuleModel.fromJson(item.data());
      _reverseLookup[rule.number] = currentIndex++;
      _rules.add(rule);
    }

    _rules.sort((a, b) => _compareRules(a, b));
    _filteredRules = _rules;
    notifyListeners();
  }

  int _compareRules(RuleModel first, RuleModel second) {
    var firstFragments = first.number.split('.');
    var secondFragments = second.number.split('.');
    firstFragments.removeWhere((s) => s.isEmpty);
    secondFragments.removeWhere((s) => s.isEmpty);

    for (var i = 0;
        i < max(firstFragments.length, secondFragments.length);
        i++) {
      var first = firstFragments.tryGet(i);
      var second = secondFragments.tryGet(i);

      if (first == null) {
        return -1;
      } else if (second == null) {
        return 1;
      }

      if (first == second) {
        continue;
      }

      final firstParsed = double.tryParse(firstFragments[i]);
      if (firstParsed != null) {
        final secondParsed = double.tryParse(secondFragments[i]);
        return firstParsed.compareTo(secondParsed!);
      } else {
        return firstFragments[i].compareTo(secondFragments[i]);
      }
    }
    throw Exception(
        "How did we get here? ${firstFragments.join(',')}, ${secondFragments.join(',')}");
  }
}
