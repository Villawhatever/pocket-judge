import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'erratum.dart';

class ErrataViewModel extends ChangeNotifier {
  final List<ErratumModel> _errata = [];

  List<ErratumModel> _filteredErrata = [];

  List<ErratumModel> get errata => _filteredErrata;

  void reset() {
    _filteredErrata = _errata;
  }

  void search(String? search) {
    if (search == null || search.isEmpty) {
      _filteredErrata = _errata;
      notifyListeners();
      return;
    }
    var fmt = search.toLowerCase();
    _filteredErrata = _errata
        .where((r) =>
            r.name.toLowerCase().contains(fmt) ||
            r.set.toLowerCase().contains(fmt))
        .toList();
    notifyListeners();
  }

  Future load() async {
    if (_errata.isNotEmpty) {
      return;
    }
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
