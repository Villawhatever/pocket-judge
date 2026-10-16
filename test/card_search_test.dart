import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pocket_judge/card_search/card.dart';
import 'package:pocket_judge/card_search/card_search_viewmodel.dart';
import 'package:pocket_judge/utils/hashing.dart';
import 'package:shouldly/shouldly.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  late Isar isar;
  late Directory tempDir;
  late SearchViewModel vm;

  Future<void> Function() setupTestIsarData(
    List<CardModel> testData, {
    bool shouldManageErrata = true,
  }) {
    return () async {
      final List<CardModel> cards = testData;

      for (int i = 0; i < cards.length; i++) {
        cards[i].id = i.toString();
        cards[i].isarId = fastHash(cards[i].id);
        if (shouldManageErrata) {
          cards[i].hasErrata = false;
        }
      }

      await isar.writeTxn(() async {
        await isar.cardModels.putAll(cards);
      });

      vm = SearchViewModel();
      await vm.initFuture;
    };
  }

  Future resetIsarData() async {
    await isar.writeTxn(() async {
      await isar.cardModels.clear();
    });
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await Isar.initializeIsarCore(download: true);
    vm = SearchViewModel();
    await vm.initFuture;
    tempDir = await Directory.systemTemp.createTemp();

    final existingInstance = Isar.getInstance('pocket-judge');
    if (existingInstance != null) {
      await existingInstance.close();
    }

    isar = await Isar.open(
      [CardModelSchema],
      directory: tempDir.path,
      name: 'pocket-judge',
    );
  });

  tearDownAll(() async {
    if (Isar.getInstance('pocket-judge') != null) {
      await isar.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Simple name tests', () {
    final card1 = CardModel.test()..name = 'Foo';
    final card2 = CardModel.test()..name = 'Bar';
    final card3 = CardModel.test()..name = 'Baz';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [card1, card2, card3],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('bar', [card2]),
      ('n:bar', [card2]),
      ('name:bar', [card2]),
      ('ba', [card2, card3]),
      ('n:ba', [card2, card3]),
      ('name:ba', [card2, card3]),
      ('foo', [card1]),
      ('n:foo', [card1]),
      ('name:foo', [card1]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Simple classification tests', () {
    group('Domain', () {
      final fury = CardModel.test()
        ..classification.domain = ['Fury']
        ..name = 'Fury';
      final calm = CardModel.test()
        ..classification.domain = ['Calm']
        ..name = 'Calm';
      final mind = CardModel.test()
        ..classification.domain = ['Mind']
        ..name = 'Mind';
      final body = CardModel.test()
        ..classification.domain = ['Body']
        ..name = 'Body';
      final chaos = CardModel.test()
        ..classification.domain = ['Chaos']
        ..name = 'Chaos';
      final order = CardModel.test()
        ..classification.domain = ['Order']
        ..name = 'Order';
      final furyCalm = CardModel.test()
        ..classification.domain = ['Fury', 'Calm']
        ..name = 'FuryCalm';
      final furyBody = CardModel.test()
        ..classification.domain = ['Fury', 'Body']
        ..name = 'FuryBody';

      setUpAll(
        Function.apply(setupTestIsarData, [
          [fury, calm, mind, body, chaos, order, furyCalm, furyBody],
        ]),
      );

      tearDownAll(resetIsarData);

      final testData = <(String input, List<CardModel> expected)>[
        ('d:r', [fury, furyCalm, furyBody]),
        ('d:g', [calm, furyCalm]),
        ('d:b', [mind]),
        ('d:o', [body, furyBody]),
        ('d:p', [chaos]),
        ('d:y', [order]),
        ('d:ro', [furyBody]),
      ];

      for (final (input, expected) in testData) {
        test('input \'$input\' expects $expected', () async {
          await vm.search(input);
          vm.cards.should.containAll(expected);
          vm.cards!.length.should.be(expected.length);
        });
      }
    });

    group('Type', () {
      final gear = CardModel.test()
        ..classification.type = ['Gear']
        ..name = 'Gear';
      final unit = CardModel.test()
        ..classification.type = ['Unit']
        ..name = 'Unit';
      final gearUnit = CardModel.test()
        ..classification.type = ['Gear', 'Unit']
        ..name = 'GearUnit';

      setUpAll(
        Function.apply(setupTestIsarData, [
          [gear, unit, gearUnit],
        ]),
      );

      tearDownAll(resetIsarData);

      final testData = <(String input, List<CardModel> expected)>[
        ('t:unit', [unit, gearUnit]),
        ('t:gear', [gear, gearUnit]),
        ('t:gear t:unit', [gearUnit]),
      ];

      for (final (input, expected) in testData) {
        test('input \'$input\' expects $expected', () async {
          await vm.search(input);
          vm.cards.should.containAll(expected);
          vm.cards!.length.should.be(expected.length);
        });
      }
    });
  });

  group('Simple paren tests', () {
    final one = CardModel.test()
      ..attributes.might = 1
      ..attributes.energy = 1
      ..attributes.power = 1
      ..name = 'One';
    final two = CardModel.test()
      ..attributes.might = 2
      ..attributes.energy = 2
      ..attributes.power = 2
      ..name = 'Two';
    final three = CardModel.test()
      ..attributes.might = 3
      ..attributes.energy = 3
      ..attributes.power = 3
      ..name = 'Three';
    final four = CardModel.test()
      ..attributes.might = 4
      ..attributes.energy = 4
      ..attributes.power = 4
      ..name = 'Four';
    final five = CardModel.test()
      ..attributes.might = 5
      ..attributes.energy = 5
      ..attributes.power = 5
      ..name = 'Five';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [one, two, three, four, five],
      ]),
    );

    tearDownAll(resetIsarData);

    group('Energy', () {
      final testData = <(String input, List<CardModel> expected)>[
        ('e:1', [one]),
        ('energy:1', [one]),
        ('e>4', [five]),
        ('energy>4', [five]),
        ('e=5', [five]),
        ('energy=5', [five]),
        ('e<=3', [one, two, three]),
        ('energy<=3', [one, two, three]),
        ('e>5', []),
        ('energy>5', []),
        ('e>=3', [three, four, five]),
        ('energy>=3', [three, four, five]),
      ];

      for (final (input, expected) in testData) {
        test('input \'$input\' expects $expected', () async {
          await vm.search(input);
          vm.cards.should.containAll(expected);
          vm.cards!.length.should.be(expected.length);
        });
      }
    });

    group('Power', () {
      final testData = <(String input, List<CardModel> expected)>[
        ('p:1', [one]),
        ('power:1', [one]),
        ('p>4', [five]),
        ('power>4', [five]),
        ('p=5', [five]),
        ('power=5', [five]),
        ('p<=3', [one, two, three]),
        ('power<=3', [one, two, three]),
        ('p>5', []),
        ('power>5', []),
        ('p>=3', [three, four, five]),
        ('power>=3', [three, four, five]),
      ];

      for (final (input, expected) in testData) {
        test('input \'$input\' expects $expected', () async {
          await vm.search(input);
          vm.cards.should.containAll(expected);
          vm.cards!.length.should.be(expected.length);
        });
      }
    });

    group('Might', () {
      final testData = <(String input, List<CardModel> expected)>[
        ('m:1', [one]),
        ('might:1', [one]),
        ('m>4', [five]),
        ('might>4', [five]),
        ('m=5', [five]),
        ('might=5', [five]),
        ('m<=3', [one, two, three]),
        ('might<=3', [one, two, three]),
        ('m>5', []),
        ('might>5', []),
        ('m>=3', [three, four, five]),
        ('might>=3', [three, four, five]),
      ];

      for (final (input, expected) in testData) {
        test('input \'$input\' expects $expected', () async {
          await vm.search(input);
          vm.cards.should.containAll(expected);
          vm.cards!.length.should.be(expected.length);
        });
      }
    });
  });

  group('Simple format tests', () {
    final legalAll = CardModel.test()
      ..legalities.constructed = 'legal'
      ..legalities.constructed_2v2 = 'legal'
      ..name = 'LegalAll';
    final legal1v1 = CardModel.test()
      ..legalities.constructed = 'legal'
      ..legalities.constructed_2v2 = 'not_legal'
      ..name = 'Legal1v1';
    final legal2v2 = CardModel.test()
      ..legalities.constructed = 'not_legal'
      ..legalities.constructed_2v2 = 'legal'
      ..name = 'Legal2v2';
    final banned2v2 = CardModel.test()
      ..legalities.constructed = 'legal'
      ..legalities.constructed_2v2 = 'banned'
      ..name = 'Banned2v2';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [legalAll, legal1v1, legal2v2, banned2v2],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('f:1v1', [legalAll, legal1v1, banned2v2]),
      ('format:1v1', [legalAll, legal1v1, banned2v2]),
      ('format:constructed', [legalAll, legal1v1, banned2v2]),
      ('f:2v2', [legalAll, legal2v2]),
      ('format:2v2', [legalAll, legal2v2]),
      ('format:magma', [legalAll, legal2v2]),
      ('format:magmachamber', [legalAll, legal2v2]),
      ('has:banned', [banned2v2]),
      ('is:banned', [banned2v2]),
      ('has:b', [banned2v2]),
      ('is:b', [banned2v2]),
      ('is:ban', [banned2v2]),
      ('has:ban', [banned2v2]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Simple errata tests', () {
    final yes = CardModel.test()
      ..hasErrata = true
      ..name = 'HasErrata';
    final no = CardModel.test()
      ..hasErrata = false
      ..name = 'NoErrata';

    setUpAll(
      Function.apply(
        setupTestIsarData,
        [
          [yes, no],
        ],
        {#shouldManageErrata: false},
      ),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('is:errata', [yes]),
      ('has:errata', [yes]),
      ('is:erratum', [yes]),
      ('has:erratum', [yes]),
      ('is:e', [yes]),
      ('has:e', [yes]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Simple watcher tests', () {
    final secret = CardModel.test()
      ..name = 'Secret'
      ..text.plain = 'secret blah blah';
    final normal = CardModel.test()
      ..name = 'Regular'
      ..text.plain = 'blah blah';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [secret, normal],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('w:blah', [secret, normal]),
      ('watcher:blah', [secret, normal]),
      ('w:blah blah', []),
      ('watcher:blah blah', []),
      ('w:"blah blah"', [secret, normal]),
      ('watcher:"blah blah"', [secret, normal]),
      ('w:secret', [secret]),
      ('watcher:secret', [secret]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Simple quote tests', () {
    final someSpaces = CardModel.test()
      ..name = 'This Card Name Has Some Spaces In It';
    final noSpaces = CardModel.test()
      ..hasErrata = false
      ..name = 'ThisCardNameHasNoSpacesInIt';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [someSpaces, noSpaces],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('name:"some space"', [someSpaces]),
      ('name:space', [someSpaces, noSpaces]),
      ('"some space"', [someSpaces]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Simple set tests', () {
    final unl = CardModel.test()
      ..name = 'UNL'
      ..set.label = 'UNL';
    final rad = CardModel.test()
      ..name = 'RAD'
      ..set.label = 'RAD';

    setUpAll(
      Function.apply(setupTestIsarData, [
        [unl, rad],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('set:UNL', [unl]),
      ('s:unl', [unl]),
      ('s=rad', [rad]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });

  group('Combiner tests', () {
    final one = CardModel.test()
      ..attributes.might = 1
      ..attributes.energy = 1
      ..attributes.power = 1
      ..name = 'One';
    final two = CardModel.test()
      ..attributes.might = 2
      ..attributes.energy = 2
      ..attributes.power = 2
      ..name = 'Two';
    final three = CardModel.test()
      ..attributes.might = 3
      ..attributes.energy = 3
      ..attributes.power = 3
      ..name = 'Three';
    final four = CardModel.test()
      ..attributes.might = 4
      ..attributes.energy = 4
      ..attributes.power = 4
      ..name = 'Four';
    final five = CardModel.test()
      ..attributes.might = 5
      ..attributes.energy = 5
      ..attributes.power = 5
      ..name = 'Five';
    final six = CardModel.test()
      ..attributes.might = 6
      ..attributes.energy = 6
      ..attributes.power = 6
      ..name = 'Also Six';
    setUpAll(
      Function.apply(setupTestIsarData, [
        [one, two, three, four, five, six],
      ]),
    );

    tearDownAll(resetIsarData);

    final testData = <(String input, List<CardModel> expected)>[
      ('(m:1 m:3)', []),
      ('(m>2 m<4)', [three]),
      ('m>2 m<4', [three]),
      ('(m=3 or m=5) o', []),
      ('(m>=2 or m=5) o', [two, four, six]),
      ('m<=4 or m=5 o', [one, two, three, four]),
      ('m>=1 m<=2 or m=5', [one, two, five]),
      ('(name="Also Six" m>=3) or m=1', [one, six]),
    ];

    for (final (input, expected) in testData) {
      test('input \'$input\' expects $expected', () async {
        await vm.search(input);
        vm.cards.should.containAll(expected);
        vm.cards!.length.should.be(expected.length);
      });
    }
  });
}
