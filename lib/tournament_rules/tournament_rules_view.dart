import 'package:flutter/material.dart' hide Stack;
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core_rules/rule.dart';
import '../widgets/rule.dart';
import '../widgets/stack.dart';

class TournamentRulesView extends StatefulWidget {
  const TournamentRulesView({super.key, required this.title});

  final String title;

  @override
  State<TournamentRulesView> createState() => TournamentRulesViewState();
}

class TournamentRulesViewState extends State<TournamentRulesView> {
  final _textController = TextEditingController();
  final _history = Stack<String>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<TournamentRulesViewModel>(context, listen: true);
    final scrollController = ItemScrollController();
    final ruleToJumpTo = 'RuleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null || jump.isEmpty) {
        return;
      }
      scrollController.jumpTo(index: viewModel.lookup[jump] ?? 0);
      _history.push(jump);
    });

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    final searchBar = SearchBar(
      hintText: "[Search]",
      onChanged: (value) => viewModel.search(value),
      onSubmitted: (value) => viewModel.search(value),
      backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      trailing: [
        IconButton(
            icon: Icon(
                _textController.text.isEmpty ? Icons.search : Icons.clear,
                size: 25,
                color: Theme.of(context).colorScheme.secondary
            ),
            onPressed: () {
              clearSearch();
            }
        ),
      ],
      controller: _textController,
    );

    void linkCallback(String ruleNumber) {
      clearSearch();
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules = context
        .select<TournamentRulesViewModel, List<RuleModel>>((vm) => vm.rules);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) {
          return;
        }
        if (_history.isNotEmpty) {
          final jump = _history.pop();
          scrollController.jumpTo(index: viewModel.lookup[jump] ?? 0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: AppWrapper(
        title: 'Tournament Rules',
        searchBar: searchBar,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: scrollController,
                itemCount: filteredRules.length,
                itemBuilder: (context, index) {
                  return RuleWidget(
                      model: filteredRules[index],
                      callback: linkCallback,
                      shouldIndent: !viewModel.isFiltered);
                }
              )
            )
          ]
        ),
      ),
    );
  }
}
