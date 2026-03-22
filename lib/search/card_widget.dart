import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../widgets/image_resolver.dart';
import 'card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.model});

  final CardModel model;

  @override
  Widget build(BuildContext context) {
    var cardMarkdown = """
**Card Type**: ${model.cardType}  
**Domain(s)**: ${model.domain == null ? 'None\n' : model.domain?.join(', ')}  
**Energy**: ${model.energy ?? 0}  
**Power**: ${model.power ?? 0}  
**Might**: ${model.might ?? 0}  
""";

    var relevantText = model.errataText ?? model.ability;
    List<InlineSpan> prettified = [];

    if (relevantText != null) {
      var currentPosition = 0;

      var matches = RegExp(r'\[.+?\]|\(.+?\)|(:(\w+_)\w+:)').allMatches(relevantText);

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

    return Column(children: [
      ExpansionTile(
        shape: BoxBorder.fromLTRB(),
        title: Text(
          model.name,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        subtitle: Text(model.idsWithImages!.keys.join(', ')),
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Markdown(
              physics: const NeverScrollableScrollPhysics(),
              data: cardMarkdown,
              padding: const EdgeInsets.only(left: 16, right: 16),
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                      code: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                      p: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
            ),
            if (relevantText != null) ...[
              const Divider(
                  height: 25,
                  thickness: 3,
                  indent: 25,
                  endIndent: 25,
                  color: Colors.white),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        children: prettified
                    ),
                ),
              ),
            ]
          ]),
        ],
      ),
    ]);
  }
}
