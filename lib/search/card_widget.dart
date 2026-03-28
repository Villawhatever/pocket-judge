import 'package:flutter/material.dart';

import '../widgets/image_resolver.dart';
import 'card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.model});

  final CardModel model;

  @override
  Widget build(BuildContext context) {
    var relevantText = model.errataText ?? model.ability;
    List<InlineSpan> prettified = [];

    if (relevantText != null) {
      var currentPosition = 0;

      var matches = RegExp(r'\[.+?\]|\(.+?\)|:\w+:').allMatches(relevantText);

      for (final match in matches) {
        final textStyle = match.group(0)!.startsWith('[')
            ? const TextStyle(fontWeight: FontWeight.bold)
            : const TextStyle(fontStyle: FontStyle.italic);

        prettified.add(
            TextSpan(text: relevantText.substring(currentPosition, match.start)));

        if (match.group(0)!.startsWith('[') || match.group(0)!.startsWith('(')) {
          final innerRunes = RegExp(r':\w+:').allMatches(match.group(0)!);
          RegExpMatch previousRune;

          if (innerRunes.isNotEmpty) {
            prettified.add(
                TextSpan(text: match.group(0)!.substring(0, innerRunes.first.start)));
            prettified.add(WidgetSpan(
                child: ImageResolver.getImage(innerRunes.first.group(0)!)
            ));

            previousRune = innerRunes.first;

            for (final currentRune in innerRunes.skip(1)) {
              if (previousRune.end != currentRune.start) {
                prettified.add(
                  TextSpan(
                    text: match.group(0)!.substring(previousRune.end, currentRune.start),
                    style: textStyle));
              }
              prettified.add(WidgetSpan(
                  child: ImageResolver.getImage(currentRune.group(0)!)
              ));
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
          prettified.add(WidgetSpan(
            child: ImageResolver.getImage(match.group(0)!)
          ));
        }
        currentPosition = match.end;
      }
      prettified.add(TextSpan(text: relevantText.substring(currentPosition)));
    }

    Widget buildCardInfo(String title, dynamic value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              children: [
                TextSpan(text: '$title\n', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value.toString()),
              ]
            ),
          ),
      );
    }

    return Column(children: [
      ExpansionTile(
        shape: BoxBorder.fromLTRB(),
        title: Text(
          model.name,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontFamily: 'Beaufort', fontWeight: FontWeight.bold),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
