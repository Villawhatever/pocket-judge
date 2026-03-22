import 'package:flutter/material.dart';

import '../widgets/image_resolver.dart';
import 'card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.model});

  final CardModel model;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> card = [];
    List<InlineSpan> prettifiedAbility = [];

    // TODO: Build this widget the right way instead of jamming newlines
    card = [
      TextSpan(
        text: 'Domain(s): ',
        style: TextStyle(
            fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: model.domain == null ? 'None\n' : '${model.domain?.join(', ')}\n',
      ),
      TextSpan(
        text: 'Energy: ',
        style: TextStyle(
            fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: '${model.energy ?? 0}\n',
      ),
      TextSpan(
        text: 'Power: ',
        style: TextStyle(
            fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: '${model.power ?? 0}\n',
      ),
      if (model.cardType == "Unit")
        ...[TextSpan(
          text: 'Might: ',
          style: TextStyle(
              fontWeight: FontWeight.bold),
        ),
          TextSpan(
            text: '${model.might ?? 0}\n',
          )],
    ];
    
    final RegExp runeRegex =
    RegExp(r'(:(\w+_)\w+:)', multiLine: true, dotAll: true);

    var relevantText = model.errataText ?? model.ability;

    if (relevantText != null) {
      var matches = runeRegex.allMatches(model.errataText ?? model.ability ?? "");

      int currentPosition = 0;

      for (final match in matches) {
        prettifiedAbility.add(
            TextSpan(text: relevantText.substring(currentPosition, match.start)));

        prettifiedAbility.add(WidgetSpan(
          child: Container(
            width: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 12,
            height: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 12,
            margin: EdgeInsets.zero,
            child: ImageResolver.getImage(match.group(1)!),
            ),
          ),
        );

        currentPosition = match.end;
      }
      prettifiedAbility.add(TextSpan(text: relevantText.substring(currentPosition)));
    }

    return Column(children: [
      ExpansionTile(
        title: Text(model.name),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            RichText(
              text: TextSpan(
                style:
                TextStyle(color: Theme.of(context).colorScheme.primary),
                children: <TextSpan>[...card],
              ),
            ),
            if (relevantText != null)
              ...[
                const Divider(
                  height: 25,
                  thickness: 3,
                  indent: 25,
                  endIndent: 25,
                  color: Colors.white),
                RichText(
                  text: TextSpan(
                    style:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                    children: [...prettifiedAbility],
                  ),
                ),
              ]
          ]
          ),
        ],
      ),
    ]);
  }
}
