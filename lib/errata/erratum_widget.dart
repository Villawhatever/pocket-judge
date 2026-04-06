import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocket_judge/widgets/expansible_header.dart';

import '../utils/extensions/context_extensions.dart';
import 'erratum.dart';

class ErratumWidget extends StatefulWidget {
  const ErratumWidget(
      {super.key, required this.model, required this.expansibleController});

  final ErratumModel model;
  final ExpansibleController expansibleController;

  @override
  State<ErratumWidget> createState() => _ErratumWidgetState();
}

class _ErratumWidgetState extends State<ErratumWidget> {
  late final ExpansibleController _expansibleController;

  @override
  initState() {
    _expansibleController = widget.expansibleController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expansible(
      headerBuilder: (context, animation) => ExpansibleHeader(
          title: widget.model.name,
          context: context,
          animation: animation,
          expansibleController: _expansibleController),
      bodyBuilder: (context, animation) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.model.newText != null) ...[
              Container(
                padding: EdgeInsetsGeometry.fromLTRB(5, 12, 5, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text('NEW TEXT', style: context.textTheme.titleMedium),
                    Text(widget.model.newText!,
                        style: context.textTheme.bodyMedium)
                  ],
                ),
              ),
              Center(
                child: FaIcon(FontAwesomeIcons.chevronUp,
                    color: context.colorScheme.secondary),
              ),
              Container(
                padding: EdgeInsetsGeometry.fromLTRB(5, 12, 5, 12),
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text('OLD TEXT', style: context.textTheme.titleMedium),
                    Text(widget.model.oldText!,
                        style: context.textTheme.bodyMedium)
                  ],
                ),
              ),
              if (widget.model.faqs?.isNotEmpty ?? false)
                const Divider(
                    height: 25,
                    thickness: 3,
                    indent: 25,
                    endIndent: 25,
                    color: Colors.white),
            ],
            if (widget.model.faqs?.isNotEmpty ?? false)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (widget.model.set != "UNL")
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(12, 5, 12, 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                  child: FaIcon(
                                      FontAwesomeIcons.triangleExclamation)),
                              Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Heads up! This FAQ is not from the most recent set. Information may be outdated.',
                                    textAlign: TextAlign.center,
                                  )),
                              Flexible(
                                  child: FaIcon(
                                      FontAwesomeIcons.triangleExclamation)),
                            ])),
                  ),
                for (final faq in widget.model.faqs!) ...[
                  Text(faq.question,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 12),
                      child: Text(faq.answer))
                ]
              ]),
          ],
        );
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
