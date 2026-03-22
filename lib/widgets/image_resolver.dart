import 'package:flutter_svg/svg.dart';

class ImageResolver {
  static SvgPicture getImage(String runeword, {double? fontSize = 12}) {
    final assetLocation = switch (runeword) {
      ':rb_energy_1:' => 'lib/assets/img/energy_1.svg',
      ':rb_energy_2:' => 'lib/assets/img/energy_2.svg',
      ':rb_energy_3:' => 'lib/assets/img/energy_3.svg',
      ':rb_energy_4:' => 'lib/assets/img/energy_4.svg',
      ':rb_energy_5:' => 'lib/assets/img/energy_5.svg',
      ':rb_energy_6:' => 'lib/assets/img/energy_6.svg',
      ':rb_energy_7:' => 'lib/assets/img/energy_7.svg',
      ':rb_energy_8:' => 'lib/assets/img/energy_8.svg',
      ':rb_energy_9:' => 'lib/assets/img/energy_9.svg',
      ':rb_energy_10:' => 'lib/assets/img/energy_10.svg',
      ':rb_energy_11:' => 'lib/assets/img/energy_11.svg',
      ':rb_energy_12:' => 'lib/assets/img/energy_12.svg',
      ':rb_might:' => 'lib/assets/img/might.svg',
      ':rb_exhaust:' => 'lib/assets/img/exhaust.svg',
      ':rb_rune_rainbow:' => 'lib/assets/img/rune_any.svg',
      ':rb_rune_body:' => 'lib/assets/img/rune_body.svg',
      ':rb_rune_calm:' => 'lib/assets/img/rune_calm.svg',
      ':rb_rune_chaos:' => 'lib/assets/img/rune_chaos.svg',
      ':rb_rune_fury:' => 'lib/assets/img/rune_fury.svg',
      ':rb_rune_mind:' => 'lib/assets/img/rune_mind.svg',
      ':rb_rune_order:' => 'lib/assets/img/rune_order.svg',
      _ => 'lib/assets/img/energy_1.svg',
    };

    return SvgPicture.asset(
      assetLocation,
      height: fontSize,
      width: fontSize,
    );
  }
}
