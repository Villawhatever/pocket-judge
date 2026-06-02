import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../firebase_options.dart';
import '../utils/sorting.dart';
import 'rule.dart';

class CoreRulesViewModel extends ChangeNotifier {
  late List<RuleModel> _rules = [];
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

    RootIsolateToken token = RootIsolateToken.instance!;
    _rules = await compute(_fetchRules, token);

    for (var i = 0; i < _rules.length; i++) {
      _reverseLookup[_rules[i].number] = i;
    }

    _filteredRules = _rules;
    notifyListeners();
  }

  Future<List<RuleModel>> _fetchRules(RootIsolateToken token) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final List<RuleModel> rules = [];

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final data =
        await FirebaseFirestore.instance.collection('core_rules').get();

    for (final item in data.docs) {
      final rule = RuleModel.fromJson(item.data());
      rules.add(rule);
    }

    rules.sort((a, b) => sortRules(a.number, b.number));

    return rules;
  }
}
