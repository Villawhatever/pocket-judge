import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pocket_judge/core_rules/rule.dart';

class RuleWidget extends StatelessWidget {
  const RuleWidget({super.key, required this.model, required this.callback});

  final RuleModel model;
  final Function callback;
  final String seeRulePattern = r'See (?:rule )?(\d+\.?)(.+?)(?=for)';

  @override
  Widget build(BuildContext context) {
    final RegExp seeRuleRegex = RegExp(seeRulePattern, multiLine: true, dotAll: true);
    var matches = seeRuleRegex.allMatches(model.text);

    List<TextSpan> fragments = [];
    int currentPosition = 0;
    for (final match in matches) {
      fragments.add(TextSpan(
        text: model.text.substring(currentPosition, match.start)
      ));

      var seeRuleNumber = match.group(1);
      if (!seeRuleNumber!.endsWith('.')) {
        seeRuleNumber += '.';
      }

      fragments.add(TextSpan(
        text: model.text.substring(match.start, match.end),
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        recognizer: TapGestureRecognizer()
          ..onTap = () => callback(seeRuleNumber)
      ));

      currentPosition = match.end;
    }
    fragments.add(TextSpan(
      text: model.text.substring(currentPosition)
    ));

    return Column(children: [
      Row(children: [
        Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                children: <TextSpan>[
                  TextSpan(
                    text: '${model.number} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                 ...fragments
                ],
              ),
        )),
      ]),
    ]);
  }
}
