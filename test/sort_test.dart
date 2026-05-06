import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_judge/utils/sorting.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  test('Sorts rules as expected', () async {
    var result = sortRules('1.13.a', '1.13.b');
    result.should.be(-1);

    result = sortRules('1.1', '2');
    result.should.be(-1);

    result = sortRules('1.1', '1.12');
    result.should.be(-1);
  });
}
