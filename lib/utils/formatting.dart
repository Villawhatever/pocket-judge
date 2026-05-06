import 'package:flutter/material.dart';

import '../constants.dart';
import 'extensions/context_extensions.dart';
import 'image_resolver.dart';

WidgetSpan _buildInlineImageWidget(String runeword) {
  return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: ImageResolver.getImage(runeword));
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width - 7, size.height);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 7, 0);
    path.lineTo(5, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

List<InlineSpan> formatCardText(String relevantText, BuildContext context,
    {bool isReminderText = false}) {
  List<InlineSpan> prettified = [];

  var currentPosition = 0;

  var matches =
      RegExp(getAbilitiesRegExp() + r'|\(.+?\)|:\w+:').allMatches(relevantText);

  var textStyle = isReminderText
      ? context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic)
      : context.textTheme.bodyMedium!;

  for (final match in matches) {
    final text = match.group(0)!;

    // Doing this split to account for e.g. 'Assault 2'
    final word = text.split(' ')[0].replaceAll(RegExp(r'[\[\]]'), '');

    textStyle = isAbilityKeyword(word)
        ? context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
        : context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic);

    if (isReminderText) {
      textStyle =
          context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic);
    }

    if (match.start != 0) {
      prettified.add(TextSpan(
          text: relevantText.substring(currentPosition, match.start),
          style: isReminderText ? textStyle : context.textTheme.bodyMedium));
    }

    if (text.startsWith('(')) {
      prettified.add(TextSpan(text: '(', style: textStyle));
      prettified.addAll(formatCardText(
          text.substring(1, text.length - 1), context,
          isReminderText: true));
      prettified.add(TextSpan(text: ')', style: textStyle));
    } else if (text.startsWith(':')) {
      prettified.add(_buildInlineImageWidget(text));
    } else if (isAbilityKeyword(word)) {
      final textColor = getAbilityColor(word, context) == yellowish
          ? context.colorScheme.tertiary
          : Colors.white;
      if (text.endsWith('[&gt;]')) {
        final fullMatch = relevantText.substring(match.start, match.end);
        // gets rid of the '[&gt;]' since we're folding it into the path thing
        final formatted =
            fullMatch.substring(1, fullMatch.length - 7).toUpperCase();
        prettified.add(
          WidgetSpan(
            child: ClipPath(
                clipper: MyCustomClipper(),
                child: Container(
                  color: getAbilityColor(word, context),
                  child: RichText(
                    text: TextSpan(
                      text: '  $formatted   ',
                      style: textStyle.copyWith(
                          color: textColor,
                          fontFamily: molde,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                )),
          ),
        );
      } else {
        prettified.add(
          WidgetSpan(
            child: Transform(
                transform: Matrix4.skewX(-0.2),
                alignment: Alignment.bottomLeft,
                child: Container(
                  color: getAbilityColor(word, context),
                  child: RichText(
                    text: TextSpan(
                      text:
                          ' ${relevantText.substring(match.start + 1, match.end - 1).toUpperCase()} ',
                      style: textStyle.copyWith(
                          color: textColor,
                          fontFamily: molde,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                )),
          ),
        );
      }
    }
    currentPosition = match.end;
  }
  final lastBit = relevantText.substring(currentPosition);
  if (lastBit.isNotEmpty) {
    prettified.add(TextSpan(
        text: relevantText.substring(currentPosition),
        style: isReminderText ? textStyle : context.textTheme.bodyMedium));
  }

  return prettified;
}
