import 'package:flutter/cupertino.dart';

import '../constants.dart';
import '../utils/extensions/context_extensions.dart';

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  final String text;
  final Color backgroundColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      WidgetSpan(
        child: Transform(
          transform: Matrix4.skewX(-0.2),
          alignment: Alignment.bottomLeft,
          child: Container(
            color: backgroundColor,
            child: RichText(
              text: TextSpan(
                text: ' $text ',
                style: context.textTheme.bodyMedium!.copyWith(
                  color: color,
                  fontFamily: molde,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
