import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../extensions/list_extensions.dart';
import 'card.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel() {
    _load();
  }

  final List<CardModel> _cards = [];
  List<CardModel> _filteredCards = [];
  Iterable<CardModel> _iterable = [];
  List<CardModel> get cards => _filteredCards;

  void search(String? search) {
    if (search == null || search.isEmpty) {
      _filteredCards = [];
      notifyListeners();
      return;
    }

    _iterable = _cards;

    var tokens = search.toLowerCase().split(' ');

    for (final token in tokens) {
      // TODO: Tokenize this for real so we can do fun things like comparisons
      final split = token.split(RegExp(r':'));
      var name = split[0];
      var value = split.tryGet(1);

      if (value == null) {
        _matchName(name);
        continue;
      }

      switch (name) {
        case 'd' || 'domain':
          _matchDomain(value);
          break;
        case 'm' || 'might':
          _matchMight(value);
          break;
        case 'e' || 'energy':
          _matchEnergy(value);
          break;
        case 'p' || 'power':
          _matchPower(value);
          break;
        case 'n' || 'name' || _:
          _matchName(search);
          break;
      }
    }

    _filteredCards = _iterable.toList();
    notifyListeners();
  }

  void _matchDomain(String value)
  {
    Map<String, String> domains =
      {
        'r': 'fury',
        'g': 'calm',
        'b': 'mind',
        'o': 'body',
        'p': 'chaos',
        'y': 'order'
      };

    _iterable = _iterable
      .where((c) => c.domain?.map((d) => d.toLowerCase()).contains(domains[value] ?? value) ?? false);
  }

  void _matchMight(String value)
  {
    _iterable = _iterable
        .where((c) => c.might != null && c.might.toString() == value);
  }

  void _matchEnergy(String value)
  {
    _iterable = _iterable
        .where((c) => c.energy != null && c.energy.toString() == value);
  }

  void _matchPower(String value)
  {
    _iterable = _iterable
        .where((c) => c.power != null && c.power.toString() == value);
  }

  void _matchName(String value)
  {
    _iterable = _iterable
      .where((c) => c.name.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'), '').contains(value));
  }

  Future _load() async {
    final cr = await rootBundle
      .loadString('lib/assets/cards.json');
    final data = jsonDecode(cr);

    Set<String> alreadyAdded = {};
    for (final item in data) {
      // TODO: Do some mapping stuff to get all IDs+Images for a given card name
      if (alreadyAdded.contains(item['name'])) {
        continue;
      }

      final card = CardModel.fromJson(item);
      _cards.add(card);
      alreadyAdded.add(card.name);
    }

    _filteredCards = [];
    notifyListeners();
  }
}
