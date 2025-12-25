import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/rule.dart';
import '../nav/menu.dart';
import '../widgets/rule.dart';
import 'core_rules_viewmodel.dart';

class CoreRulesView extends StatelessWidget {
  const CoreRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CoreRulesViewModel>(context, listen: true);
    final scrollController = ItemScrollController();
    final textController = TextEditingController();
    const String ruleToJumpTo = 'ruleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null) {
        return;
      }
      scrollController.jumpTo(index: viewModel.lookup[jump]!);
      localStorage.clear();
    });

    void search(String? value) {
      textController.text = value ?? '';
      viewModel.search(value);
    }

    final searchBar = SearchBar(
      hintText: "Search",
      onChanged: (value) => search(value),
      onSubmitted: (value) => textController.text = value,
    );

    void linkCallback(String ruleNumber) {
      search(null);
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules = context.select<CoreRulesViewModel, List<RuleModel>>((vm) => vm.rules);

    return Scaffold(
      drawer: const Menu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: searchBar
      ),
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
      ),
    );
  }
}
