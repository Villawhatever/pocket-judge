import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pocket_judge/card_search/card.dart';

// Import your generated schemas here
// import 'package:your_app/models/user.dart';

void main() {
  late Isar isar;
  late Directory tempDir;

  // Initialize the native binaries once before all tests run
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  // Re-initialize a clean database instance for every individual test
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();

    isar = await Isar.open(
      [CardModelSchema], // Pass your compiled schemas here
      directory: tempDir.path,
    );
  });

  // Clean up and wipe files after every individual test
  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Should successfully insert and retrieve a User', () async {
    final newUser = User()..name = 'Jane Doe';

    // Transactions must use writeTxn
    await isar.writeTxn(() async {
      await isar.users.put(newUser);
    });

    final retrievedUser = await isar.users
        .filter()
        .nameEqualTo('Jane Doe')
        .findFirst();

    expect(retrievedUser, isNotNull);
    expect(retrievedUser!.name, equals('Jane Doe'));
  });
}
