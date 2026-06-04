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
  throw Exception('How did we get here?');
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

  await addMissingErrata(isar);
  await addEquipmentEffects(isar);

  dev.log('Done updating isar data');
  return;
}

Future<void> addMissingErrata(Isar isar) async {
  final guards = await isar.cardModels
      .filter()
      .nameMatches('Guards!')
      .findFirst();
  guards!.text.rich =
      '[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\nPlay a 2 :rb_might: Sand Soldier unit token. Then do this: You may pay :rb_rune_order: to ready it.';

  final relentlessPursuit = await isar.cardModels
      .filter()
      .nameMatches('Relentless Pursuit')
      .findFirst();
  relentlessPursuit!.text.rich =
      '[Action] (Play on your turn or in showdowns.)\nMove a friendly unit. You may attach up to one Equipment with the same controller to it. This turn, that unit has \'When I conquer, you may move me to my base.\'';

  final deathFromBelow = await isar.cardModels
      .filter()
      .nameMatches('Death from Below')
      .findFirst();
  deathFromBelow!.text.rich =
      'Kill a unit at a battlefield. Then, if it had 3 :rb_might: or less, do this: you may play this from your trash for :rb_rune_rainbow:.';

  final boneSkewer = await isar.cardModels
      .filter()
      .nameMatches('Bone Skewer')
      .findFirst();

  boneSkewer!.text.rich =
      '[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\nChoose a battlefield. An opponent reveals their hand. You may choose a unit from it. They play that unit to that battlefield, ignoring any and all costs. If they do, then do this: [Stun] it. (It doesn\'t deal combat damage this turn.)';

  final deceiver = await isar.cardModels
      .filter()
      .nameMatches('LeBlanc - Deceiver')
      .findFirst();

  deceiver!.text.rich =
      'When you conquer or hold, you may discard 1 and exhaust me to play a ready Reflection unit token there. Then do this: It becomes a copy of another unit there. Give it [Temporary].';

  final mirrorImage = await isar.cardModels
      .filter()
      .nameMatches('Mirror Image')
      .findFirst();

  mirrorImage!.text.rich =
      'Choose a unit. Play a ready Reflection unit token to your base. Then do this: It becomes a copy of that unit. Give it [Temporary]. (Kill it at the start of its controller\'s Beginning Phase, before scoring.)';

  final keeperOfMasks = await isar.cardModels
      .filter()
      .nameMatches('Keeper of Masks')
      .findFirst();

  keeperOfMasks!.text.rich =
      '[Hidden] (Hide now for :rb_rune_rainbow: to react with later for :rb_energy_0:.)\n[Temporary] (Kill me at the start of my controller\'s Beginning Phase, before scoring.)\nWhen you play me, play two Reflection unit tokens here. Then do this: They become copies of me.';

  final rengar = await isar.cardModels
      .filter()
      .nameMatches('Rengar - Trophy Hunter')
      .findFirst();

  rengar!.text.rich =
      '[Ambush] (You may play me as a [Reaction] to a battlefield where you have units.)\nI can [Ambush] to a battlefield where there are enemy units, even if you don\'t have units there.';

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
}

Future<void> addEquipmentEffects(Isar isar) async {
  List<CardModel> equipment = [];
  try {
    equipment.addAll([
      await updateEquipment(
        isar,
        'Serrated Dirk',
        mightBonus: '+0',
        effect: '[Assault 2] (+2 :rb_might: while I\'m an attacker)',
      ),

      await updateEquipment(
        isar,
        'Recurve Bow',
        mightBonus: '+0',
        effect: 'When I attack or defend, deal 2 to an enemy unit here.',
      ),

      await updateEquipment(
        isar,
        'Blighted Battleaxe',
        mightBonus: '+4',
        effect:
            'At the end of your turn, if I didn\'t conquer this turn, unattach this and deal 4 to me.',
      ),

      await updateEquipment(isar, 'Long Sword', mightBonus: '+2'),

      await updateEquipment(
        isar,
        'Skyfall of Areion',
        mightBonus: '+2',
        effect: 'My hold effects are also conquer effects, and vice versa.',
      ),

      await updateEquipment(
        isar,
        'Doran\'s Shield',
        mightBonus: '+1',
        effect: '[Tank] (I must be assigned combat damage first)',
      ),

      await updateEquipment(
        isar,
        'Soul Sword',
        mightBonus: '+1',
        effect:
            '[Level 3][&gt;] I have an addition +1 :rb_might:. (While you have 3+ XP, get the effect.)',
      ),

      await updateEquipment(
        isar,
        'Brutalizer',
        mightBonus: '+1',
        effect:
            'If this was attached to me this turn, I have an additional +2 :rb_might:.',
      ),

      await updateEquipment(
        isar,
        'Guardian Angel',
        mightBonus: '+1',
        effect:
            'If I would die, kill Guardian Angel instead. Heal me, exhaust me, and recall me.',
      ),

      await updateEquipment(isar, 'Sterak\'s Gage', mightBonus: '+3'),

      await updateEquipment(
        isar,
        'Svellsongur',
        mightBonus: '+0',
        effect:
            'As this is attached to a unit, copy that unit\'s text to this Equipment\'s effect text for as long as this is attached to it.',
      ),

      await updateEquipment(
        isar,
        'Cloth Armor',
        mightBonus: '+0',
        effect: '[Shield 2] (+2 :rb_might: while I\'m a defender.)',
      ),

      await updateEquipment(
        isar,
        'Experimental Hexplate',
        mightBonus: '+1',
        effect: 'I am a Mech.',
      ),

      await updateEquipment(
        isar,
        'World Atlas',
        mightBonus: '+2',
        effect: 'When I hold, play two Gold gear tokens exhausted.',
      ),

      await updateEquipment(
        isar,
        'The Zero Drive',
        mightBonus: '+2',
        effect: '[Deathknell] — Banish me. (When I die, get the effect.)]',
      ),

      await updateEquipment(isar, 'Doran\'s Blade', mightBonus: '+2'),

      await updateEquipment(
        isar,
        'Hunter\'s Machete',
        mightBonus: '+2',
        effect: '[Hunt] (When I conquer or hold, gain 1 XP.)',
      ),

      await updateEquipment(
        isar,
        'Hexdrinker',
        mightBonus: '+1',
        effect:
            '[Deflect] (Opponents must pay :rb_rune_rainbow: to choose me with a spell or ability.)',
      ),

      await updateEquipment(
        isar,
        'Warmog\'s Armor',
        mightBonus: '+1',
        effect:
            'When I conquer, buff me. (If I don\'t have a buff, I get a +1 :rb_might: buff.)',
      ),

      await updateEquipment(
        isar,
        'Trinity Force',
        mightBonus: '+2',
        effect: 'When I hold, score 1 point.',
      ),

      await updateEquipment(
        isar,
        'Boneshiver',
        mightBonus: '+2',
        effect: 'When I conquer, channel 1 rune exhausted.',
      ),

      await updateEquipment(
        isar,
        'Doran\'s Ring',
        mightBonus: '+1',
        effect: 'When I conquer, discard 1, then draw 1.',
      ),

      await updateEquipment(
        isar,
        'Boots of Swiftness',
        mightBonus: '+2',
        effect: '[Ganking] (I can move from battlefield to battlefield.',
      ),
      await updateEquipment(
        isar,
        'Cull',
        mightBonus: '+1',
        effect: 'When I conquer, play a Gold gear token exhausted.',
      ),

      await updateEquipment(isar, 'Edge of Night', mightBonus: '+2'),

      await updateEquipment(
        isar,
        'Last Rites',
        mightBonus: '+2',
        effect:
            'When I conquer or hold, you may play a unit from your trash. (You still pay its costs.)',
      ),

      await updateEquipment(
        isar,
        'Eye of the Herald',
        mightBonus: '+0',
        effect: 'When I move, play a +1 :rb_might: Recruit unit token here.',
      ),

      await updateEquipment(isar, 'Shepherd\'s Heirloom', mightBonus: '+2'),

      await updateEquipment(isar, 'B.F. Sword', mightBonus: '+3'),

      await updateEquipment(
        isar,
        'Sacred Shears',
        mightBonus: '+1',
        effect: '[Deathknell] — Draw 1. (When I die, get the effect.)',
      ),

      await updateEquipment(isar, 'Blade of the Ruined King', mightBonus: '+4'),

      await updateEquipment(isar, 'Spinning Axe', mightBonus: '+3'),

      await updateEquipment(
        isar,
        'Hextech Gauntlets',
        mightBonus: '+3',
        effect:
            'When I conquer, if you assigned 3 or more excess damage, draw 1.',
      ),

      await updateEquipment(
        isar,
        'Forgefire Cape',
        mightBonus: '+3',
        effect: 'When I attack or defend, deal 2 to all enemy units here.',
      ),

      await updateEquipment(
        isar,
        'Rabadon\'s Deathcrown',
        mightBonus: '+3',
        effect:
            'Your spells and abilities deal 3 bonus Damage (while this is attached).',
      ),

      await updateEquipment(
        isar,
        'Shurelya\'s Requiem',
        mightBonus: '+2',
        effect:
            'Your units here have [Ganking]. (We can move from battlefield to battlefield.)',
      ),
    ]);

    await isar.writeTxn(() async {
      isar.cardModels.putAll(equipment);
    });
    dev.log('== Done updating ${equipment.length} equipment. ==');
  } catch (e) {
    dev.log('BROKE: $e');
  }
}

Future<CardModel> updateEquipment(
  Isar isar,
  String name, {
  String? effect,
  String? mightBonus,
}) async {
  final equipment = await isar.cardModels
      .filter()
      .nameMatches(name)
      .findFirst();
  equipment!.mightBonus = mightBonus;
  equipment.text.effect = effect;
  dev.log('Updated ${equipment.name}');
  return equipment;
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
          existingCard.images!.add(
            ImageData(id: card.riftboundId, imgUrl: card.media.imageUrl),
          );
        }
        continue;
      }

      alreadyAdded[card.name!] = card;
      existingCardNames.add(card.name!);
      dev.log('Adding ${card.name}');
      cards.add(card);
    }
    page++;
  } while (page <= totalNumPages);

  for (final card in cards) {
    card.images!.sort((a, b) => _sortIds(a.id!, b.id!));
  }
  return cards;
}
