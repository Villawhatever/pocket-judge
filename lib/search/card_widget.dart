import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import '../utils/formatters.dart';
import 'card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.model});

  final CardModel model;

  @override
  Widget build(BuildContext context) {
    var relevantText = model.errataText ?? model.ability ?? '';

    var prettified = formatCardText(relevantText, context);

    Widget buildCardInfo(String title, dynamic value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(value.toString(), style: context.textTheme.bodyMedium),
              ]));
    }

    return Column(children: [
      ExpansionTile(
        dense: true,
        shape: BoxBorder.fromLTRB(),
        tilePadding: EdgeInsets.zero,
        title: Text(
          model.name,
          style: context.textTheme.titleMedium,
        ),
        subtitle: Text(model.idsWithImages!.keys.join(', '),
            style: context.textTheme.bodyMedium!
                .copyWith(fontStyle: FontStyle.italic)),
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(children: [
                  TableRow(children: [
                    buildCardInfo('Domain(s)', model.domain?.join(', ')),
                    SizedBox.shrink()
                  ]),
                  TableRow(children: [
                    buildCardInfo('Card Type', model.cardType),
                    model.cardType.toLowerCase() == 'unit'
                        ? buildCardInfo('Might', model.might)
                        : SizedBox.shrink(),
                  ]),
                  TableRow(children: [
                    model.energy == null
                        ? SizedBox.shrink()
                        : buildCardInfo('Energy', model.energy),
                    model.power == null
                        ? SizedBox.shrink()
                        : buildCardInfo('Power', model.power),
                  ])
                ]),
                RichText(
                  text: TextSpan(
                      style: context.textTheme.bodyMedium,
                      children: prettified),
                ),
              ]),
        ],
      ),
    ]);
  }
}
