import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petitparser/core.dart';
import 'package:pocket_judge/card_search/parsing/ast_to_isar_query.dart';
import 'package:pocket_judge/card_search/parsing/parser.dart';

import 'card.dart';

class SearchViewModel extends ChangeNotifier {
  List<CardModel> _filteredCards = [];
  Iterable<CardModel> _iterable = [];

  List<CardModel> get cards => _filteredCards;
  late String _searchSyntax = '';
  late Isar isar;
  late final Future initFuture;
  String get searchSyntax => _searchSyntax;

  SearchViewModel() {
    initFuture = _initialize();
  }

  Future<void> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        Isar.getInstance('pocket-judge') ??
        await Isar.open(
          [CardModelSchema],
          directory: dir.path,
          name: 'pocket-judge',
        );
  }

  void reset() {
    _filteredCards = [];
  }

  Future search(String? search) async {
    if (search == null || search.isEmpty) {
      _filteredCards = [];
      notifyListeners();
      return;
    }

    final parser = SearchParserDefinition().build();
    final Result result = parser.parse(search);
    final query = IsarQueryBuilder.buildQuery(isar.cardModels, result.value);

    _iterable = await query.findAll();

    _filteredCards = _iterable.toList();
    _filteredCards.sort((a, b) => a.name.compareTo(b.name));

    notifyListeners();
  }

  Future load() async {
    if (_searchSyntax.isEmpty) {
      _searchSyntax = await rootBundle.loadString(
        'lib/assets/search_syntax.md',
      );
    }

    _filteredCards = [];
    notifyListeners();
  }
}
