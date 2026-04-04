import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/image_resolver.dart';
import 'extensions/context_extensions.dart';

WidgetSpan _buildInlineImageWidget(String runeword) {
  return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: ImageResolver.getImage(runeword));
}

List<InlineSpan> doSomething(String relevantText, BuildContext context) {
  List<InlineSpan> prettified = [];

  var currentPosition = 0;
  var matches =
      RegExp(getAbilitiesRegExp() + r'|\(.+?\)|:\w+:').allMatches(relevantText);

  for (final match in matches) {
    var text = match.group(0)!;
    // Doing this split to account for e.g. 'Assault 2'
    final textStyle = isAbilityKeyword(text.split(' ')[0])
        ? context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
        : context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic);

    prettified.add(
        TextSpan(text: relevantText.substring(currentPosition, match.start)));

    if (text.startsWith('(')) {
      final innerRunes = RegExp(r':\w+:').allMatches(text);
      RegExpMatch previousRune;

      if (innerRunes.isNotEmpty) {
        prettified.add(TextSpan(
            text: text.substring(0, innerRunes.first.start), style: textStyle));
        prettified.add(_buildInlineImageWidget(innerRunes.first.group(0)!));

        previousRune = innerRunes.first;

        for (final currentRune in innerRunes.skip(1)) {
          if (previousRune.end != currentRune.start) {
            prettified.add(TextSpan(
                text: text.substring(previousRune.end, currentRune.start),
                style: textStyle));
          }
          prettified.add(_buildInlineImageWidget(currentRune.group(0)!));
          previousRune = currentRune;
        }
        prettified.add(TextSpan(
            text: relevantText.substring(
                match.start + previousRune.end, match.end),
            style: textStyle));
      } else {
        prettified.add(TextSpan(
            text: relevantText.substring(match.start, match.end),
            style: textStyle));
      }
    } else if (text.startsWith(':')) {
      prettified.add(_buildInlineImageWidget(text));
    } else if (isAbilityKeyword(text.split(' ')[0])) {
      prettified.add(
        TextSpan(
          text: relevantText.substring(match.start, match.end),
          style: textStyle.copyWith(
              color: getAbilityColor(text.split(' ')[0], context)),
        ),
      );
    }
    currentPosition = match.end;
  }
  prettified.add(TextSpan(text: relevantText.substring(currentPosition)));
  return prettified;
}
