import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_judge/constants.dart';
import 'package:pocket_judge/core_rules/rule.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';

class RuleWidget extends StatelessWidget {
  const RuleWidget({
    super.key,
    required this.model,
    required this.callback,
    this.shouldIndent = true,
  });

  final RuleModel model;
  final Function callback;
  final bool shouldIndent;

  String _getParentRule() {
    final fragments = model.number.split('.');
    final parentRuleNumber = fragments
        .take(math.min(2, fragments.length))
        .join('.');

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
    final String seeRulePattern =
        r'See (?:rule )?(\d+(?:\.?[\w\d]\.?)+).+?(?= for)|\[.+?\]';
    final RegExp seeRuleRegex = RegExp(
      seeRulePattern,
      multiLine: true,
      dotAll: true,
    );

    var matches = seeRuleRegex.allMatches(model.text);

    List<TextSpan> fragments = [];
    int currentPosition = 0;

    for (final match in matches) {
      if (match.start > 0) {
        fragments.add(
          TextSpan(text: model.text.substring(currentPosition, match.start)),
        );
      }

      final text = match.group(0)!;
      if (text.startsWith('[')) {
        final isPenalty = penalties.any((p) => text.contains(p));
        final penaltyStyle = context.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: yellowish,
        );
        fragments.add(
          TextSpan(
            text: text,
            style: isPenalty ? penaltyStyle : context.textTheme.bodyMedium!,
          ),
        );
      } else {
        var seeRuleNumber = match.group(1)!.split(' ')[0];
        if (!seeRuleNumber.endsWith('.')) {
          seeRuleNumber += '.';
        }

        fragments.add(
          TextSpan(
            text: model.text.substring(match.start, match.end),
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.colorScheme.secondary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => callback(model.number, seeRuleNumber),
          ),
        );
      }

      currentPosition = match.end;
    }
    fragments.add(TextSpan(text: model.text.substring(currentPosition)));

    final double leftPadding = shouldIndent
        ? math.max(20 * (countCharacters(model.number, '.') - 1), 0)
        : 0;
    final richText = RichText(
      text: TextSpan(
        style: context.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '${model.number} ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...fragments,
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, 0, 0, 12),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => callback(model.number, _getParentRule()),
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(text: richText.text.toPlainText()),
              );
              HapticFeedback.vibrate();
            },
            child: Row(children: [Flexible(child: richText)]),
          ),
        ],
      ),
    );
  }
}
