import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import '../widgets/image_resolver.dart';
import 'card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.model});

  final CardModel model;

  WidgetSpan _buildInlineImageWidget(String runeword) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: ImageResolver.getImage(runeword)
    );
  }

  @override
  Widget build(BuildContext context) {
    var relevantText = model.errataText ?? model.ability;
    List<InlineSpan> prettified = [];

    if (relevantText != null) {
      var currentPosition = 0;

      var matches = RegExp(r'\[.+?\]|\(.+?\)|:\w+:').allMatches(relevantText);

      for (final match in matches) {
        final textStyle = match.group(0)!.startsWith('[')
          ? context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
          : context.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic);

        prettified.add(
          TextSpan(text: relevantText.substring(currentPosition, match.start)));

        if (match.group(0)!.startsWith('[') || match.group(0)!.startsWith('(')) {
          final innerRunes = RegExp(r':\w+:').allMatches(match.group(0)!);
          RegExpMatch previousRune;

          if (innerRunes.isNotEmpty) {
            prettified.add(
              TextSpan(text: match.group(0)!.substring(0, innerRunes.first.start)));
            prettified.add(_buildInlineImageWidget(innerRunes.first.group(0)!));

            previousRune = innerRunes.first;

            for (final currentRune in innerRunes.skip(1)) {
              if (previousRune.end != currentRune.start) {
                prettified.add(
                  TextSpan(
                    text: match.group(0)!.substring(previousRune.end, currentRune.start),
                    style: textStyle));
              }
              prettified.add(_buildInlineImageWidget(currentRune.group(0)!));
              previousRune = currentRune;
            }
            prettified.add(TextSpan(
              text: relevantText.substring(match.start + previousRune.end, match.end),
              style: textStyle));
          } else {
            prettified.add(TextSpan(
              text: relevantText.substring(match.start, match.end),
              style: textStyle));
          }
        } else if (match.group(0)!.startsWith(':')) {
          prettified.add(_buildInlineImageWidget(match.group(0)!));
        }
        currentPosition = match.end;
      }
      prettified.add(TextSpan(text: relevantText.substring(currentPosition)));
    }

    Widget buildCardInfo(String title, dynamic value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
            Text(value.toString(), style: context.textTheme.bodyMedium),
          ]
        )
      );
    }

    return Column(children: [
      ExpansionTile(
        shape: BoxBorder.fromLTRB(),
        tilePadding: EdgeInsets.zero,
        title: Text(
          model.name,
          style: context.textTheme.titleMedium,
        ),
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Table(
                    children: [
                      TableRow(
                          children: [
                            buildCardInfo('Printing(s)', model.idsWithImages!.keys.join(', ')),
                            buildCardInfo('Domain(s)', model.domain?.join(', ')),
                          ]
                      ),
                      TableRow(
                          children: [
                            buildCardInfo('Card Type', model.cardType),
                            model.cardType.toLowerCase() == 'unit'
                                ? buildCardInfo('Might', model.might)
                                : SizedBox.shrink(),
                          ]
                      ),
                      TableRow(
                          children: [
                            model.energy == null
                                ? SizedBox.shrink()
                                : buildCardInfo('Energy', model.energy),
                            model.power == null
                                ? SizedBox.shrink()
                                : buildCardInfo('Power', model.power),
                          ]
                      )
                    ]
                ),
                if (relevantText != null) ...[
                  RichText(
                    text: TextSpan(
                        style: context.textTheme.bodyMedium,
                        children: prettified
                    ),
                  ),
                ]
              ]),
          ),
        ],
      ),
    ]);
  }
}
