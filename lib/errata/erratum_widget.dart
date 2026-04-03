import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocket_judge/constants.dart';

import '../utils/extensions/context_extensions.dart';
import 'erratum.dart';

class ErratumWidget extends StatefulWidget {
  const ErratumWidget({super.key, required this.model});

  final ErratumModel model;

  @override
  State<ErratumWidget> createState() => _ErratumWidgetState();
}

class _ErratumWidgetState extends State<ErratumWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          ExpansionTile(
            shape: BoxBorder.fromLTRB(),
            tilePadding: EdgeInsets.zero,
            expandedAlignment: Alignment.center,
            title: Text(
              widget.model.name,
              style: context.textTheme.titleMedium
            ),
            subtitle: Text(
              widget.model.set,
              style: context.textTheme.bodyMedium
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if(widget.model.newText != null)
                    ... [
                      Container(
                        padding: EdgeInsetsGeometry.fromLTRB(5, 12, 5, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'NEW TEXT',
                              style: context.textTheme.titleMedium
                            ),
                            Text(
                              widget.model.newText!,
                              style: context.textTheme.bodyMedium
                            )
                          ],
                        ),
                      ),
                      Center(
                        child : FaIcon(FontAwesomeIcons.chevronUp, color: context.colorScheme.secondary),
                      ),
                      Container(
                        padding: EdgeInsetsGeometry.fromLTRB(5, 12, 5, 12),
                        decoration: BoxDecoration(
                          color: context.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                                'OLD TEXT',
                                style: context.textTheme.titleMedium
                            ),
                            Text(
                                widget.model.oldText!,
                                style: context.textTheme.bodyMedium
                            )
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
                  if(widget.model.faqs?.isNotEmpty ?? false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                  Flexible(child: FaIcon(FontAwesomeIcons.triangleExclamation)),
                                  Flexible(
                                      flex: 10,
                                      child: Text(
                                        'Heads up! This FAQ is not from the most recent set. Information may be outdated.',
                                        textAlign: TextAlign.center,
                                      )
                                  ),
                                  Flexible(child: FaIcon(FontAwesomeIcons.triangleExclamation)),
                                ]
                              )
                            ),
                          ),
                        for (final faq in widget.model.faqs!)
                          ... [
                            Text(faq.question,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                            Padding(
                              padding: EdgeInsetsGeometry.only(bottom: 12),
                              child: Text(faq.answer)
                            )

                          ]
                      ]
                    ),
                ],
              )
            ],
          ),
       ],
    );
  }
}
