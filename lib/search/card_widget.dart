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

    if (relevantText != null) {
      relevantText = relevantText.replaceAllMapped(RegExp(r'\[.+?\]'), (match) {
        return '**${match.group(0)}**';
      });
      relevantText = relevantText.replaceAllMapped(RegExp(r'\(.+?\)'), (match) {
        return '_${match.group(0)}_';
      });
      relevantText =
          relevantText.replaceAllMapped(RegExp(r'(:(\w+_)\w+:)'), (match) {
        return '![might](resource:${match.group(0)})';
      });
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
            MarkdownBody(
              data: cardMarkdown,
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
              MarkdownBody(
                data: relevantText,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                        code: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        p: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                imageBuilder: (Uri uri, String? title, String? alt) {
                  return Container(
                      child: ImageResolver.getImage(uri.path,
                          fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontSize
                                  ?.toDouble() ??
                              12.0));
                },
              ),
            ]
          ]),
        ],
      ),
    ]);
  }
}
