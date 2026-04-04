import 'package:flutter/cupertino.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';

Map<K, V> createMultiKeyMap<K, V>(Map<List<K>, V> input) {
  final result = <K, V>{};
  for (var entry in input.entries) {
    for (var key in entry.key) {
      result[key] = entry.value;
    }
  }
  return result;
}

class AbilityColors {
  static final Map<String, Color> _abilityColors = createMultiKeyMap({
    [
      'Accelerate',
      'Action',
      'Ambush',
      'Buff',
      'Hidden',
      'Legion',
      'Quick-Draw',
      'Reaction',
      'Repeat',
    ]: const Color(0xff68c5ad),
    [
      'Assault',
      'Backline',
      'Shield',
      'Tank',
    ]: const Color(0xffe58ab4),
    ['Equip', 'Mighty', 'Unique', 'Vision', 'Weaponmaster']:
        const Color(0xffc4c4c4),
    ['Deflect', 'Ganking', 'Hunt', 'Level', 'Temporary']:
        const Color(0xffd7ed7a),
  });

  static String buildAbilitiesRegexString() {
    var foo =
        _abilityColors.keys.map((ability) => ability + r'\b(?: \d)?').join('|');
    return foo;
  }

  static bool contains(String ability) {
    return _abilityColors.keys.any((x) => x == ability);
  }

  static Color get(String ability, BuildContext context) {
    return _abilityColors[ability] ?? context.colorScheme.primary;
  }
}
