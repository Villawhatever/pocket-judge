import 'package:flutter/material.dart' hide Stack;
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core_rules/rule.dart';
import '../utils/extensions/context_extensions.dart';
import '../widgets/rule.dart';
import '../widgets/search_bar.dart';
import '../widgets/stack.dart';

class TournamentRulesView extends StatefulWidget {
  const TournamentRulesView({super.key, required this.title});

  final String title;

  @override
  State<TournamentRulesView> createState() => _TournamentRulesViewState();
}

class _TournamentRulesViewState extends State<TournamentRulesView> {
  final _textController = TextEditingController();
  final _history = Stack<String>();
  late TournamentRulesViewModel viewModel;

  @override
  void dispose() {
    _textController.dispose();
    viewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<TournamentRulesViewModel>(context, listen: true);
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

    final searchBar = CustomSearchBar(
        textController: _textController,
        onChanged: viewModel.search,
        onSubmitted: viewModel.search,
        onClear: clearSearch);

    void linkCallback(String ruleNumber) {
      clearSearch();
      localStorage.setItem(ruleToJumpTo, ruleNumber);
    }

    final filteredRules = context
        .select<TournamentRulesViewModel, List<RuleModel>>((vm) => vm.rules);

    final indexList = context
        .select<TournamentRulesViewModel, List<TrIndex>>((vm) => vm.indexMap);

    TrIndex? waitingTopLevelItem;
    var topLevelIndices = [];
    var childIndices = [];

    for (final item in indexList) {
      if (!item.isSubrule) {
        if (waitingTopLevelItem != null) {
          topLevelIndices.add(ExpansionTile(
            shape: BoxBorder.fromLTRB(),
            tilePadding: EdgeInsets.zero,
            title: Text(
              waitingTopLevelItem.text,
              style: context.textTheme.titleMedium,
            ),
            children: [...childIndices],
          ));
        }
        childIndices = [];
        waitingTopLevelItem = item;
      } else {
        childIndices.add(InkWell(
          onTap: () {
            scrollController.jumpTo(index: item.lookup);
            Navigator.pop(context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(item.number,
                    style: context.textTheme.bodyMedium!
                        .copyWith(color: context.colorScheme.secondary)),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: EdgeInsetsGeometry.only(left: 10),
                  child: Text(item.text,
                      style: context.textTheme.bodyMedium!
                          .copyWith(color: context.colorScheme.secondary)),
                ),
              ),
            ],
          ),
        ));
      }
    }

    topLevelIndices.add(ExpansionTile(
      shape: BoxBorder.fromLTRB(),
      tilePadding: EdgeInsets.zero,
      title:
          Text(waitingTopLevelItem!.text, style: context.textTheme.titleMedium),
      children: [...childIndices],
    ));

    var indexDrawer = Drawer(
      child: Padding(
        padding: MediaQuery.of(context).viewPadding,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 15, bottom: 1),
              child: Text('PENALTY INDEX', style: context.textTheme.titleLarge),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 12, right: 12),
                child: ListView(
                    padding: MediaQuery.of(context).viewPadding,
                    children: [...topLevelIndices]),
              ),
            ),
          ],
        ),
      ),
    );
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
          clearSearch();
          SystemNavigator.pop();
        }
      },
      child: AppWrapper(
        title: widget.title,
        searchBar: searchBar,
        endDrawer: indexDrawer,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: ScrollablePositionedList.builder(
                  itemScrollController: scrollController,
                  itemCount: filteredRules.length,
                  itemBuilder: (context, index) {
                    return RuleWidget(
                        model: filteredRules[index],
                        callback: linkCallback,
                        shouldIndent: !viewModel.isFiltered);
                  }))
        ]),
      ),
    );
  }
}
