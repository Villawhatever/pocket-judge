import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import '../utils/formatters.dart';
import '../widgets/expansible_header.dart';
import 'card.dart';

class CardWidget extends StatefulWidget {
  const CardWidget(
      {super.key, required this.model, required this.expansibleController});

  final CardModel model;
  final ExpansibleController expansibleController;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  late final ExpansibleController _expansibleController;

  @override
  initState() {
    _expansibleController = widget.expansibleController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var relevantText = widget.model.errataText ?? widget.model.ability ?? '';

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

    return Expansible(
      headerBuilder: (context, animation) => ExpansibleHeader(
          title: widget.model.name,
          context: context,
          animation: animation,
          expansibleController: _expansibleController),
      bodyBuilder: (context, animation) {
        return Padding(
            padding: EdgeInsetsGeometry.only(left: 5, right: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Table(children: [
                    TableRow(children: [
                      buildCardInfo(
                          'Domain(s)', widget.model.domain?.join(', ')),
                      SizedBox.shrink()
                    ]),
                    TableRow(children: [
                      buildCardInfo('Card Type', widget.model.cardType),
                      widget.model.cardType.toLowerCase() == 'unit'
                          ? buildCardInfo('Might', widget.model.might)
                          : SizedBox.shrink(),
                    ]),
                    TableRow(children: [
                      widget.model.energy == null
                          ? SizedBox.shrink()
                          : buildCardInfo('Energy', widget.model.energy),
                      widget.model.power == null
                          ? SizedBox.shrink()
                          : buildCardInfo('Power', widget.model.power),
                    ])
                  ]),
                  RichText(
                    text: TextSpan(
                        style: context.textTheme.bodyMedium,
                        children: prettified),
                  ),
                ]));
      },
      controller: _expansibleController,
      expansibleBuilder: (
        context,
        header,
        body,
        animation,
      ) =>
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, body]),
    );
  }
}
