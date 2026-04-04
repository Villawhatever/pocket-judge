import 'package:flutter/cupertino.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';
import 'package:pocket_judge/utils/map_helpers.dart';

const String spiegel = 'Spiegel';
const String beaufort = 'Beaufort';

final Map<String, Color> _abilityColors = createMultiKeyMap({
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
  ['Deflect', 'Ganking', 'Hunt', 'Level', 'Temporary']: const Color(0xffd7ed7a),
});

String getAbilitiesRegExp() {
  return _abilityColors.keys
      .map((ability) => ability + r'\b(?: \d)?')
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
