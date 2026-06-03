import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
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
  final isar = await Isar.open(name: 'pocket-judge', [
    CardModelSchema,
  ], directory: dir.path);

  final cards = await getCards();

  await isar.writeTxn(() async {
    await isar.cardModels.putAll(cards);
  });

  final guards = await isar.cardModels
      .filter()
      .nameMatches("Guards!")
      .findFirst();
  guards!.text.rich =
      "[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\nPlay a 2 :rb_might: Sand Soldier unit token. Then do this: You may pay :rb_rune_order: to ready it.";

  final relentlessPursuit = await isar.cardModels
      .filter()
      .nameMatches("Relentless Pursuit")
      .findFirst();
  relentlessPursuit!.text.rich =
      "[Action] (Play on your turn or in showdowns.)\nMove a friendly unit. You may attach up to one Equipment with the same controller to it. This turn, that unit has \"When I conquer, you may move me to my base.\"";

  final deathFromBelow = await isar.cardModels
      .filter()
      .nameMatches("Death from Below")
      .findFirst();
  deathFromBelow!.text.rich =
      "Kill a unit at a battlefield. Then, if it had 3 :rb_might: or less, do this: you may play this from your trash for :rb_rune_rainbow:.";

  final boneSkewer = await isar.cardModels
      .filter()
      .nameMatches("Bone Skewer")
      .findFirst();

  boneSkewer!.text.rich =
      "[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\nChoose a battlefield. An opponent reveals their hand. You may choose a unit from it. They play that unit to that battlefield, ignoring any and all costs. If they do, then do this: [Stun] it. (It doesn't deal combat damage this turn.)";

  final deceiver = await isar.cardModels
      .filter()
      .nameMatches("LeBlanc - Deceiver")
      .findFirst();

  deceiver!.text.rich =
      "When you conquer or hold, you may discard 1 and exhaust me to play a ready Reflection unit token there. Then do this: It becomes a copy of another unit there. Give it [Temporary].";

  final mirrorImage = await isar.cardModels
      .filter()
      .nameMatches("Mirror Image")
      .findFirst();

  mirrorImage!.text.rich =
      "Choose a unit. Play a ready Reflection unit token to your base. Then do this: It becomes a copy of that unit. Give it [Temporary]. (Kill it at the start of its controller's Beginning Phase, before scoring.)";

  final keeperOfMasks = await isar.cardModels
      .filter()
      .nameMatches("Keeper of Masks")
      .findFirst();

  keeperOfMasks!.text.rich =
      "[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\n[Temporary] (Kill me at the start of my controller's Beginning Phase, before scoring.)\nWhen you play me, play two Reflection unit tokens here. Then do this: They become copies of me.";

  final rengar = await isar.cardModels
      .filter()
      .nameMatches("Rengar - Trophy Hunter")
      .findFirst();

  rengar!.text.rich =
      "[Ambush] (You may play me as a [Reaction] to a battlefield where you have units.)\nI can [Ambush] to a battlefield where there are enemy units, even if you don't have units there.";

  await isar.writeTxn(() async {
    await isar.cardModels.putAll([
      guards,
      relentlessPursuit,
      deathFromBelow,
      boneSkewer,
      deceiver,
      mirrorImage,
      keeperOfMasks,
      rengar,
    ]);
  });

  return;
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
        if (!existingCard!.images!.any(
          (i) => i.imgUrl! == card.media.imageUrl,
        )) {
          dev.log('\tDuplicate card found: ${card.name}');
          existingCard.images!.add(
            ImageData(id: card.riftboundId, imgUrl: card.media.imageUrl),
          );
        }
        continue;
      }

      alreadyAdded[card.name!] = card;
      existingCardNames.add(card.name!);
      dev.log('New card found: ${card.name}');
      cards.add(card);
    }
    page++;
  } while (page <= totalNumPages);

  for (final card in cards) {
    card.images!.sort((a, b) => _sortIds(a.id!, b.id!));
  }
  return cards;
}
