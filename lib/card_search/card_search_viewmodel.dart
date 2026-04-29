import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/extensions/list_extensions.dart';
import 'card.dart';

class SearchViewModel extends ChangeNotifier {
  final List<CardModel> _cards = [];
  List<CardModel> _filteredCards = [];
  Iterable<CardModel> _iterable = [];
  List<CardModel> get cards => _filteredCards;
  late String _searchSyntax = '';
  String get searchSyntax => _searchSyntax;

  void reset() {
    _filteredCards = [];
  }

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
        case 'w' || 'watcher':
          _matchWatcherText(value);
          break;
        case 's' || 'set':
          _matchSet(value);
          break;
        case 'n' || 'name' || _:
          _matchName(search);
          break;
      }
    }

    _filteredCards = _iterable.toList();
    notifyListeners();
  }

  void _matchDomain(String value) {
    Map<String, String> domains = {
      'r': 'fury',
      'g': 'calm',
      'b': 'mind',
      'o': 'body',
      'p': 'chaos',
      'y': 'order'
    };

    _iterable = _iterable.where((c) =>
        c.domain
            ?.map((d) => d.toLowerCase())
            .contains(domains[value] ?? value) ??
        false);
  }

  void _matchMight(String value) {
    _iterable =
        _iterable.where((c) => c.might != null && c.might.toString() == value);
  }

  void _matchEnergy(String value) {
    _iterable = _iterable
        .where((c) => c.energy != null && c.energy.toString() == value);
  }

  void _matchPower(String value) {
    _iterable =
        _iterable.where((c) => c.power != null && c.power.toString() == value);
  }

  void _matchSet(String value) {
    // TODO: Pull this somewhere else so it's more configurable and reusable.
    Map<String, String> sets = {
      'ogn': 'origins',
      'ogs': 'provinggrounds',
      'sfd': 'spiritforged',
      'unl': 'unleashed',
    };

    _iterable = _iterable
        .where((c) => _flatten(c.cardSet).contains(sets[value] ?? value));
  }

  /* TODO: This currently only matches eg "kaisa" instead of "Kai'Sa"
   * Likely most common user experience, but modify this to handle when people
   * DO use proper punctuation.
   */
  void _matchName(String value) {
    _iterable = _iterable.where((c) =>
        _flatten(c.name).contains(value) ||
        // TODO: Get rid of this realName hacky bullshit
        c.cardType == "Legend" && _flatten(c.realName ?? '').contains(value));
  }

  void _matchWatcherText(String value) {
    _iterable = _iterable.where((c) {
      final String relevantText = _flatten(c.errataText ?? c.ability ?? '');
      return relevantText.contains(value);
    });
  }

  Future load() async {
    if (_searchSyntax.isEmpty) {
      _searchSyntax =
          await rootBundle.loadString('lib/assets/search_syntax.md');
    }

    if (_cards.isNotEmpty) {
      return;
    }

    final cr = await rootBundle.loadString('lib/assets/cards.json');
    final data = jsonDecode(cr);

    Map<String, CardModel> alreadyAdded = {};
    Set<String> existingCardNames = {};

    for (final item in data) {
      if (existingCardNames.contains(item['name'])) {
        var existingCard = alreadyAdded[item['name']];
        existingCard!.images!
            .add(ImageData(id: item['id'], imgUrl: item['image_url']));
        continue;
      }

      final card = CardModel.fromJson(item);
      _cards.add(card);
      existingCardNames.add(card.name);
      alreadyAdded[card.name] = card;
    }
    for (final card in _cards) {
      card.images!.sort((a, b) => sortIds(a.id, b.id));
    }
    _filteredCards = [];
    notifyListeners();
  }

  int sortIds(String first, String second) {
    var firstFragments = first.split('-');
    var secondFragments = second.split('-');
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

      return firstFragments[i].compareTo(secondFragments[i]);
    }
    throw Exception("How did we get here?");
  }

  String _flatten(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }
}
