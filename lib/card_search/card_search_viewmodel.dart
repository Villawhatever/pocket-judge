import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/extensions/json_extensions.dart';
import '../utils/extensions/list_extensions.dart';
import 'card.dart' hide Set;

class SearchViewModel extends ChangeNotifier {
  final List<CardModel> _cards = [];
  List<CardModel> _filteredCards = [];
  Iterable<CardModel> _iterable = [];

  List<CardModel> get cards => _filteredCards;
  late String _searchSyntax = '';
  late Isar isar;

  String get searchSyntax => _searchSyntax;

  SearchViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [CardModelSchema],
      directory: dir.path,
      name: 'pocket-judge',
    );
  }

  void reset() {
    _filteredCards = [];
  }

  void search(String? search) async {
    if (search == null || search.isEmpty) {
      _filteredCards = [];
      notifyListeners();
      return;
    }

    _iterable = await isar.cardModels.where().findAll();

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
        case 'n' || 'name':
          _matchName(value);
          break;
        case _:
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
      'y': 'order',
    };

    _iterable = _iterable.where(
      (c) =>
          c.classification.domain
              ?.map((d) => d.toLowerCase())
              .contains(domains[value] ?? value) ??
          false,
    );
  }

  void _matchMight(String value) {
    _iterable = _iterable.where(
      (c) =>
          c.attributes.might != null && c.attributes.might.toString() == value,
    );
  }

  void _matchEnergy(String value) {
    _iterable = _iterable.where(
      (c) =>
          c.attributes.energy != null &&
          c.attributes.energy.toString() == value,
    );
  }

  void _matchPower(String value) {
    _iterable = _iterable.where(
      (c) =>
          c.attributes.power != null && c.attributes.power.toString() == value,
    );
  }

  void _matchSet(String value) {
    _iterable = _iterable.where(
      (c) => _flatten(c.set.setId ?? '').contains(value),
    );
  }

  void _matchName(String value) {
    _iterable = _iterable.where(
      (c) =>
          _flatten(c.name).contains(value) ||
          (c.classification.type == 'Legend' &&
              (c.tags?.any((t) => t == value) ?? false)),
    );
  }

  void _matchWatcherText(String value) {
    _iterable = _iterable.where((c) {
      final String relevantText = _flatten(
        (c.text.rich ?? '') + (c.text.plain ?? ''),
      );
      return relevantText.contains(value);
    });
  }

  Future load() async {
    if (_searchSyntax.isEmpty) {
      _searchSyntax = await rootBundle.loadString(
        'lib/assets/search_syntax.md',
      );
    }

    if (_cards.isNotEmpty) {
      return;
    }

    _filteredCards = [];
    notifyListeners();
  }

  String _flatten(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }
}

class CardSet {
  const CardSet({
    required this.id,
    required this.name,
    required this.setId,
    required this.cardCount,
    required this.publishedOn,
  });

  final String id;
  final String name;
  final String setId;
  final int cardCount;
  final DateTime publishedOn;

  factory CardSet.fromJson(Map<String, dynamic> json) {
    return CardSet(
      id: json.tryGet('id'),
      name: json.tryGet('name'),
      setId: json.tryGet('set_id'),
      cardCount: json.tryGet('card_count'),
      publishedOn: DateTime.parse(json.tryGet('published_on') ?? ''),
    );
  }

  @override
  String toString() {
    return name;
  }
}
