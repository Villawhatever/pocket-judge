import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_judge/utils/extensions/list_extensions.dart';

import 'card_search/card.dart' hide Set;

int _sortIds(String first, String second) {
  var firstFragments = first.split('-');
  var secondFragments = second.split('-');
  firstFragments.removeWhere((s) => s.isEmpty);
  secondFragments.removeWhere((s) => s.isEmpty);

  for (var i = 0; i < max(firstFragments.length, secondFragments.length); i++) {
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CardModelSchema],
    directory: dir.path,
  );

  var cards = await getCards();
  await isar.writeTxn(() async {
    await isar.cardModels.putAll(cards);
  });
}

Future<List<CardModel>> getCards() async {
  var page = 1;
  var totalNumPages = 1;
  final List<CardModel> cards = [];
  do {
    var uri = Uri.https('api.riftcodex.com', '/cards', {
      'page': page.toString(),
      'size': '50',
      'sort': 'name',
      'dir': '1',
    });

    var response = await http.read(uri);
    var cardData = json.decode(response) as Map<String, dynamic>;

    totalNumPages = cardData['pages'];

    Map<String, CardModel> alreadyAdded = {};
    Set<String> existingCardNames = {};

    for (final item in cardData['items']) {
      final card = CardModel.fromJson(item);

      if (existingCardNames.contains(card.name!)) {
        var existingCard = alreadyAdded[card.name!];
        if (!existingCard!.images!
            .any((i) => i.imgUrl! == card.media.imageUrl)) {
          existingCard.images!.add(
              ImageData(id: card.riftboundId, imgUrl: card.media.imageUrl));
        }
        continue;
      }

      alreadyAdded[card.name!] = card;
      existingCardNames.add(card.name!);

      cards.add(card);
    }
    page++;
  } while (page <= totalNumPages);

  for (final card in cards) {
    card.images!.sort((a, b) => _sortIds(a.id!, b.id!));
  }
  return cards;
}
