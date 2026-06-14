import 'package:flutter/cupertino.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';
import 'package:pocket_judge/utils/map_helpers.dart';

const String beaufort = 'Beaufort';
const String molde = 'Molde';
const String spiegel = 'Spiegel';

const Color greenish = Color(0xff157661);
const Color reddish = Color(0xffca3b70);
const Color grayish = Color(0xff717171);
const Color yellowish = Color(0xff90b236);

final penalties = [
  'No Penalty',
  'Warning',
  'Game Loss',
  'Match Loss',
  'Disqualification',
];

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
  ['Assault', 'Backline', 'Shield', 'Tank']: reddish,
  [
    'Add',
    'Equip',
    'Mighty',
    'Predict',
    'Stun',
    'Unique',
    'Vision',
    'Weaponmaster',
  ]: grayish,
  ['Deathknell', 'Deflect', 'Ganking', 'Hunt', 'Level', 'Temporary']: yellowish,
});

String getAbilitiesRegExp() {
  return r'\[.+?(?:\b \d+)?\](?:\[>\])?';
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
