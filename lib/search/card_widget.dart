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
        prettified.add(
            TextSpan(text: relevantText.substring(currentPosition, match.start)));

        if (match.group(0)!.startsWith('[')) {
          prettified.add(TextSpan(
              text: relevantText.substring(match.start, match.end),
              style: TextStyle(fontWeight: FontWeight.bold)));
        } else if (match.group(0)!.startsWith('(')) {
          prettified.add(TextSpan(
              text: relevantText.substring(match.start, match.end),
              style: TextStyle(fontStyle: FontStyle.italic)));
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
