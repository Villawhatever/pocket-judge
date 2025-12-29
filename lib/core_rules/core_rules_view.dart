import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'rule.dart';
import '../widgets/rule.dart';
import 'core_rules_viewmodel.dart';

class CoreRulesView extends StatefulWidget {
  const CoreRulesView({super.key});

  @override
  State<CoreRulesView> createState() => CoreRulesViewState();
}

class CoreRulesViewState extends State<CoreRulesView> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoreRulesViewModel>(context, listen: true);
    final scrollController = ItemScrollController();
    final ruleToJumpTo = 'RuleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null || jump.isEmpty) {
        return;
      }
      scrollController.jumpTo(index: viewModel.lookup[jump]!);
    });

    final searchBar = SearchBar(
      hintText: "Search",
      onChanged: (value) => viewModel.search(value),
      onSubmitted: (value) => viewModel.search(value),
      controller: _textController,
    );

    void linkCallback(String ruleNumber) {
      _textController.clear();
      viewModel.search(null);
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules = context.select<CoreRulesViewModel, List<RuleModel>>((vm) => vm.rules);

    return AppWrapper(
        title: searchBar,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
          child: ScrollablePositionedList.separated(
            itemScrollController: scrollController,
            itemCount: filteredRules.length,
            itemBuilder: (context, index) {
              return RuleWidget(model: filteredRules[index], callback: linkCallback);
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          ),
        )
    );
  }
}
