import 'package:flutter/material.dart';
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
    List<TextSpan> erratum = [];

    // TODO: Build this widget the right way instead of jamming newlines
    if (widget.model.newText != null) {
      erratum = [
        const TextSpan(
          text: 'NEW TEXT\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: '${widget.model.newText}\n\n'),
        TextSpan(
          text: 'OLD TEXT\n',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.error),
        ),
        TextSpan(
          text: widget.model.oldText,
          style: TextStyle(color: context.colorScheme.error),
        )
      ];
    }

    List<TextSpan> faqs = [];
    widget.model.faqs?.forEach((faq) {
      faqs.add(TextSpan(
        text: '${faq.question}\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      faqs.add(TextSpan(text: '${faq.answer}\n\n'));
    });

    return Column(children: [
      ExpansionTile(
          shape: BoxBorder.fromLTRB(),
          tilePadding: EdgeInsets.zero,
          title: Text(
            widget.model.name,
            style: TextStyle(color: context.colorScheme.secondary, fontFamily: Fonts.beaufort, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.model.set),
          children: [
            Column(children: [
              RichText(
                text: TextSpan(
                  style:
                      TextStyle(color: context.colorScheme.primary),
                  children: <TextSpan>[...erratum],
                ),
              ),
              if (erratum.isNotEmpty && faqs.isNotEmpty)
                const Divider(
                    height: 25,
                    thickness: 3,
                    indent: 25,
                    endIndent: 25,
                    color: Colors.white),
              RichText(
                text: TextSpan(
                  style:
                      TextStyle(color: context.colorScheme.primary),
                  children: <TextSpan>[...faqs],
                ),
              ),
            ])
          ])
    ]);
  }
}
