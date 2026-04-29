import 'package:flutter/cupertino.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';
import 'package:pocket_judge/utils/map_helpers.dart';

const String spiegel = 'Spiegel';
const String beaufort = 'Beaufort';

const Color greenish = Color(0xff68c5ad);
const Color reddish = Color(0xffe58ab4);
const Color grayish = Color(0xffc4c4c4);
const Color yellowish = Color(0xffd7ed7a);

final Map<String, Color> _abilityColors = createMultiKeyMap({
  [
    'Accelerate',
    'Action',
    'Ambush',
    'Buff',
    'Hidden',
    'Hunt',
    'Legion',
    'Level',
    'Quick-Draw',
    'Reaction',
    'Repeat',
  ]: greenish,
  [
    'Assault',
    'Backline',
    'Shield',
    'Tank',
  ]: reddish,
  ['Equip', 'Mighty', 'Predict', 'Unique', 'Vision', 'Weaponmaster']: grayish,
  ['Deathknell', 'Deflect', 'Ganking', 'Hunt', 'Level', 'Temporary']: yellowish,
});

String getAbilitiesRegExp() {
  return _abilityColors.keys
      .map((ability) => ability + r'\b(?: \d+)?')
      .join('|');
}

bool isAbilityKeyword(String ability) {
  return _abilityColors.keys.any((x) => x == ability);
}

Color getAbilityColor(String ability, BuildContext context) {
  return _abilityColors[ability] ?? context.colorScheme.primary;
}

class PreferencesKeys extends InheritedWidget {
  static PreferencesKeys? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PreferencesKeys>();

  const PreferencesKeys({required super.child, required Key super.key});

  @override
  bool updateShouldNotify(PreferencesKeys oldWidget) => false;
}
