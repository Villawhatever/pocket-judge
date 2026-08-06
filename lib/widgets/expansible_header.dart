import 'package:flutter/material.dart';
import 'package:pocket_judge/constants.dart';
import 'package:pocket_judge/widgets/backer.dart';

import '../utils/extensions/context_extensions.dart';

class ExpansibleHeader extends StatelessWidget {
  const ExpansibleHeader({
    super.key,
    required this.title,
    required this.context,
    required this.animation,
    this.hasErrata = false,
    this.legalities = const [],
    required this.expansibleController,
  });

  final String title;
  final BuildContext context;
  final Animation<double> animation;
  final bool hasErrata;
  final List<String>? legalities;
  final ExpansibleController expansibleController;

  void _toggleExpand() {
    expansibleController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleExpand(),
      child: Container(
        padding: EdgeInsetsGeometry.fromLTRB(12, 12, 7, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: context.colorScheme.inversePrimary,
        ),
        constraints: BoxConstraints(minHeight: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleMedium,
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
              ),
            ),
            if (hasErrata)
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: Backer(
                  text: ' ERRATA ',
                  color: context.colorScheme.tertiary,
                  backgroundColor: yellowish,
                ),
              ),
            if (legalities?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: Backer(
                  text: ' BANNED ',
                  color: context.colorScheme.primary,
                  backgroundColor: reddish,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: expansibleController.isExpanded
                    ? Icon(
                        Icons.arrow_drop_up_outlined,
                        key: ValueKey<int>(1),
                        color: context.colorScheme.secondary,
                        size: 25,
                      )
                    : Icon(
                        Icons.arrow_drop_down_outlined,
                        key: ValueKey<int>(2),
                        color: context.colorScheme.secondary,
                        size: 25,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
