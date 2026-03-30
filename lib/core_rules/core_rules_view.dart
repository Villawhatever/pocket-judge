import 'package:flutter/material.dart' hide Stack;
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:pocket_judge/widgets/search.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'rule.dart';
import '../widgets/rule.dart';
import '../widgets/stack.dart';
import 'core_rules_viewmodel.dart';

class CoreRulesView extends StatefulWidget {
  const CoreRulesView({super.key, required this.title});

  final String title;

  @override
  State<CoreRulesView> createState() => CoreRulesViewState();
}

class CoreRulesViewState extends State<CoreRulesView> {
  final _textController = TextEditingController();
  final _history = Stack<String>();
  late CoreRulesViewModel viewModel;

  @override
  void dispose() {
    _textController.dispose();
    viewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CoreRulesViewModel>(context, listen: true);
    final scrollController = ItemScrollController();
    final ruleToJumpTo = 'RuleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null || jump.isEmpty) {
        return;
      }
      localStorage.setItem(ruleToJumpTo, '');
      scrollController.jumpTo(index: viewModel.lookup[jump] ?? 0);
      _history.push(jump);
    });

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    final searchBar = CustomSearchBar(
        textController: _textController,
        onChanged: viewModel.search,
        onSubmitted: viewModel.search,
        onClear: clearSearch);

    void linkCallback(String ruleNumber) {
      clearSearch();
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules =
        context.select<CoreRulesViewModel, List<RuleModel>>((vm) => vm.rules);

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
        title: widget.title,
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
        )
      ),
    );
  }
}
