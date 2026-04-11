import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_judge/core_rules/rule.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';

class RuleWidget extends StatelessWidget {
  const RuleWidget(
      {super.key,
      required this.model,
      required this.callback,
      this.shouldIndent = true});

  final RuleModel model;
  final Function callback;
  final bool shouldIndent;

  String _getParentRule() {
    final fragments = model.number.split('.');
    final parentRuleNumber =
        fragments.take(math.min(2, fragments.length)).join('.');

    return parentRuleNumber.endsWith('.')
        ? parentRuleNumber
        : '$parentRuleNumber.';
  }

  double countCharacters(String text, String charToCount) {
    double count = 0;
    for (final c in text.characters) {
      if (c == charToCount) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final String seeRulePattern = r'See (?:rule )?(\d+\.?)(.+?)(?=for)';
    final RegExp seeRuleRegex =
        RegExp(seeRulePattern, multiLine: true, dotAll: true);

    var matches = seeRuleRegex.allMatches(model.text);

    List<TextSpan> fragments = [];
    int currentPosition = 0;

    for (final match in matches) {
      fragments.add(
          TextSpan(text: model.text.substring(currentPosition, match.start)));

      var seeRuleNumber = match.group(1);
      if (!seeRuleNumber!.endsWith('.')) {
        seeRuleNumber += '.';
      }

      fragments.add(TextSpan(
          text: model.text.substring(match.start, match.end),
          style: context.textTheme.bodyMedium!
              .copyWith(color: context.colorScheme.secondary),
          recognizer: TapGestureRecognizer()
            ..onTap = () => callback(seeRuleNumber)));

      currentPosition = match.end;
    }
    fragments.add(TextSpan(text: model.text.substring(currentPosition)));

    final double leftPadding = shouldIndent
        ? math.max(20 * (countCharacters(model.number, '.') - 1), 0)
        : 0;
    final richText = RichText(
      text: TextSpan(
        style: context.textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: '${model.number} ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...fragments
        ],
      ),
    );

    return Padding(
        padding: EdgeInsets.fromLTRB(leftPadding, 0, 0, 12),
        child: Column(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => callback(_getParentRule()),
            onLongPress: () {
              Clipboard.setData(
                  ClipboardData(text: richText.text.toPlainText()));
              HapticFeedback.vibrate();
            },
            child: Row(children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style: context.textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: '${model.number} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...fragments
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]));
  }
}
