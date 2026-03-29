import 'dart:math';

import 'extensions/list_extensions.dart';

int sortRules(String first, String second) {
  var firstFragments = first.split('.');
  var secondFragments = second.split('.');
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

    final firstParsed = double.tryParse(firstFragments[i]);
    if (firstParsed != null) {
      final secondParsed = double.tryParse(secondFragments[i]);
      return firstParsed.compareTo(secondParsed!);
    } else {
      return firstFragments[i].compareTo(secondFragments[i]);
    }
  }
  throw Exception("How did we get here?");
}