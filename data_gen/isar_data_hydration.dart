import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_judge/card_search/card.dart' hide Set;
import 'package:pocket_judge/errata/erratum.dart';
import 'package:pocket_judge/utils/extensions/list_extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(name: 'pocket-judge', [
    CardModelSchema,
  ], directory: dir.path);

  final cards = await getCards();

  await isar.writeTxn(() async {
    await isar.cardModels.putAll(cards);
  });

  final errata = await addErrata(isar);

  await isar.writeTxn(() async {
    await isar.cardModels.putAll(errata);
  });

  dev.log('Done updating isar data');
  return;
}

Future<List<CardModel>> addErrata(Isar isar) async {
  final String contents = await rootBundle.loadString('lib/assets/errata.json');
  final List<dynamic> data = jsonDecode(contents);
  final List<CardModel> modifiedCards = [];

  for (final item in data) {
    final erratum = ErratumModel.fromJson(item);
    final card = await isar.cardModels
        .filter()
        .nameEndsWith(erratum.name, caseSensitive: false)
        .findFirst();
    try {
      final enrichedText = _enrichText(
        card!.classification.domain ?? [],
        erratum.newText!,
      );
      card.text.rich = enrichedText;
      modifiedCards.add(card);
    } catch (e) {
      dev.log('Error on card ${erratum.name}: $e');
      stdout.writeln('Error on card ${erratum.name}: $e');
    }
  }

  return modifiedCards;
}

String _enrichText(List<String> domains, String text) {
  text = text.replaceAllMapped(RegExp(r'\[(\d+)\]'), (Match match) {
    final number = match.group(1);
    return ':rb_energy_$number:';
  });

  text = text.replaceAll('[A]', ':rb_rune_rainbow:');
  text = text.replaceAll('[C]', ':rb_rune_${domains.first.toLowerCase()}:');
  text = text.replaceAll('[E]', ':rb_exhaust:');
  text = text.replaceAll('[M]', ':rb_might:');

  return text;
}

Future<List<CardModel>> getCards() async {
  final String contents = await rootBundle.loadString(
    'lib/assets/scraped_gallery.json',
  );
  final List<dynamic> data = jsonDecode(contents);

  final List<CardModel> cards = [];
  Map<String, CardModel> alreadyAdded = {};
  Set<String> existingCardNames = {};

  for (final item in data) {
    try {
      final card = CardModel.fromJson(item);
      if (existingCardNames.contains(card.name)) {
        var existingCard = alreadyAdded[card.name];
        if (!existingCard!.images!.any(
          (i) => i.imgUrl! == card.media.imageUrl,
        )) {
          existingCard.images!.add(
            ImageData(id: card.riftboundId, imgUrl: card.media.imageUrl),
          );
        }
        continue;
      }

      alreadyAdded[card.name] = card;
      existingCardNames.add(card.name);
      cards.add(card);
    } catch (e) {
      dev.log('${item['name']} => $e');
      rethrow;
    }
    continue;
  }

  for (final card in cards) {
    card.images?.sort((a, b) => _sortIds(a.id!, b.id!));
  }
  return cards;
}

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
  throw Exception('How did we get here?');
}
