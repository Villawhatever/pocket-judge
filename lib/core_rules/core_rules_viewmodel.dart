import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        .where(
          (r) =>
              r.text.toLowerCase().contains(search!) ||
              r.number.toLowerCase().contains(search),
        )
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

    final data = await _cacheAndCheckForNew(token);

    for (final item in data.docs) {
      final rule = RuleModel.fromJson(item.data());
      rules.add(rule);
    }

    rules.sort((a, b) => sortRules(a.number, b.number));

    return rules;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _cacheAndCheckForNew(
    RootIsolateToken token,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();

    QuerySnapshot<Map<String, dynamic>> cachedSnapshot;
    try {
      cachedSnapshot = await firestore
          .collection('core_rules')
          .get(const GetOptions(source: Source.cache));
    } catch (e) {
      return _fetchFromServerAndSave(firestore, prefs, token);
    }

    try {
      DocumentSnapshot metadataDoc = await firestore
          .collection('metadata')
          .doc('updates')
          .get(const GetOptions(source: Source.server));

      if (metadataDoc.exists) {
        final serverTimestamp =
            (metadataDoc.data() as Map)['cr_last_updated'] as int;
        final localTimestamp = prefs.getInt('cr_last_updated') ?? 0;

        if (serverTimestamp > localTimestamp) {
          return _fetchFromServerAndSave(firestore, prefs, token);
        }
      }
    } catch (e) {
      // Fallback to cached data if server check fails
    }

    return cachedSnapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchFromServerAndSave(
    FirebaseFirestore firestore,
    SharedPreferences prefs,
    RootIsolateToken token,
  ) async {
    QuerySnapshot<Map<String, dynamic>> serverSnapshot = await firestore
        .collection('core_rules')
        .get(const GetOptions(source: Source.server));

    await prefs.setInt(
      'cr_last_updated',
      DateTime.now().millisecondsSinceEpoch,
    );

    return serverSnapshot;
  }
}
