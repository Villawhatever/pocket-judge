import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'erratum.dart';

class ErrataViewModel extends ChangeNotifier {
  ErrataViewModel() {
    _load();
  }

  final List<ErratumModel> _errata = [];

  List<ErratumModel> _filteredErrata = [];

  List<ErratumModel> get errata => _filteredErrata;

  void search(String? search) {
    if (search == null || search.isEmpty) {
      _filteredErrata = _errata;
      notifyListeners();
      return;
    }
    search = search.toLowerCase();
    _filteredErrata =
      _errata
      .where((r) => r.name.toLowerCase().contains(search!))
      .toList();
    notifyListeners();
  }

  Future _load() async {
    final cr = await rootBundle.loadString('lib/assets/errata.json');
    final data = jsonDecode(cr);

    for (final item in data) {
      final erratum = ErratumModel.fromJson(item);
      _errata.add(erratum);
    }

    _filteredErrata = _errata;
    notifyListeners();
  }
}