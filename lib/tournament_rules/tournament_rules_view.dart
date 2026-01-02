import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core_rules/rule.dart';
import '../widgets/rule.dart';

class TournamentRulesView extends StatefulWidget {
  const TournamentRulesView({super.key});

  @override
  State<TournamentRulesView> createState() => TournamentRulesViewState();
}

class TournamentRulesViewState extends State<TournamentRulesView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TournamentRulesViewModel>(context, listen: true);
    final scrollController = ItemScrollController();
    final ruleToJumpTo = 'RuleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null || jump.isEmpty) {
        return;
      }
      scrollController.jumpTo(index: viewModel.lookup[jump]!);
    });

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    final searchBar = SearchBar(
      hintText: "[Search]",
      onChanged: (value) => viewModel.search(value),
      onSubmitted: (value) => viewModel.search(value),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      trailing: [
        Opacity(
            opacity: _textController.text.isEmpty ? 0.01 : 1.0,
            child: IconButton(
                icon: Icon(Icons.clear, size: 25),
                onPressed: () {
                  clearSearch();
                }
            )
        ),
      ],
      controller: _textController,
    );

    void linkCallback(String ruleNumber) {
      clearSearch();
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules = context.select<TournamentRulesViewModel, List<RuleModel>>((vm) => vm.rules);

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
