import 'package:flutter/material.dart' hide Stack;
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core_rules/rule.dart';
import '../utils/extensions/context_extensions.dart';
import '../utils/extensions/list_extensions.dart';
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
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late TournamentRulesViewModel _viewModel;
  late String? _firstVisibleRuleNumber;
  late List<RuleModel>? _filteredRules;

  @override
  void initState() {
    super.initState();

    _itemPositionsListener.itemPositions.addListener(() {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final index = positions
            .where((position) => position.itemTrailingEdge > 0)
            .reduce(
              (min, position) => position.itemLeadingEdge < min.itemLeadingEdge
                  ? position
                  : min,
            )
            .index;
        _firstVisibleRuleNumber = _filteredRules?.tryGet(index)?.number;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _viewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel = Provider.of<TournamentRulesViewModel>(context, listen: true);

    final scrollController = ItemScrollController();
    final ruleToJumpTo = 'RuleToJumpTo';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jump = localStorage.getItem(ruleToJumpTo);
      if (jump == null || jump.isEmpty) {
        return;
      }
      localStorage.setItem(ruleToJumpTo, '');
      scrollController.jumpTo(index: _viewModel.lookup[jump] ?? 0);
    });

    clearSearch() {
      _textController.clear();
      _viewModel.search(null);
    }

    final searchBar = CustomSearchBar(
      textController: _textController,
      onChanged: _viewModel.search,
      onSubmitted: _viewModel.search,
      onClear: clearSearch,
    );

    void linkCallback(
      String originatingRuleNumber,
      String destinationRuleNumber,
    ) {
      clearSearch();
      localStorage.setItem(ruleToJumpTo, destinationRuleNumber);
      if (originatingRuleNumber != destinationRuleNumber) {
        _history.push(originatingRuleNumber);
      } else if (_firstVisibleRuleNumber != null) {
        _history.push(_firstVisibleRuleNumber!);
      }
    }

    final indexList = context.select<TournamentRulesViewModel, List<TrIndex>>(
      (vm) => vm.indexMap,
    );

    TrIndex? waitingTopLevelItem;
    var topLevelIndices = [];
    var childIndices = [];

    for (final item in indexList) {
      if (!item.isSubrule) {
        if (waitingTopLevelItem != null) {
          topLevelIndices.add(
            ExpansionTile(
              shape: BoxBorder.fromLTRB(),
              tilePadding: EdgeInsets.zero,
              title: Text(
                waitingTopLevelItem.text,
                style: context.textTheme.titleMedium,
              ),
              children: [...childIndices],
            ),
          );
        }
        childIndices = [];
        waitingTopLevelItem = item;
      } else {
        childIndices.add(
          InkWell(
            onTap: () {
              scrollController.jumpTo(index: item.lookup);
              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    item.number,
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: Text(
                      item.text,
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: context.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    topLevelIndices.add(
      ExpansionTile(
        shape: BoxBorder.fromLTRB(),
        tilePadding: EdgeInsets.zero,
        title: Text(
          waitingTopLevelItem?.text ?? '',
          style: context.textTheme.titleMedium,
        ),
        children: [...childIndices],
      ),
    );

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
                  children: [...topLevelIndices],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    _filteredRules = context.select<TournamentRulesViewModel, List<RuleModel>>(
      (vm) => vm.rules,
    );

    void jump() {
      final jump = _history.pop();
      scrollController.jumpTo(index: _viewModel.lookup[jump] ?? 0);
      setState(() {});
    }

    Widget? fab;
    if (_history.isNotEmpty) {
      fab = FloatingActionButton.extended(
        onPressed: jump,
        backgroundColor: context.colorScheme.inversePrimary,
        label: Row(
          children: [
            FittedBox(
              child: Text(
                'Go back to ${_history.peek}',
                style: context.textTheme.bodyMedium!.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.navigate_before, color: context.colorScheme.secondary),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) {
          return;
        }
        if (_history.isNotEmpty) {
          final jump = _history.pop();
          scrollController.jumpTo(index: _viewModel.lookup[jump] ?? 0);
        } else {
          clearSearch();
          SystemNavigator.pop();
        }
      },
      child: AppWrapper(
        title: widget.title,
        searchBar: searchBar,
        endDrawer: indexDrawer,
        fab: fab,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ScrollablePositionedList.builder(
                itemPositionsListener: _itemPositionsListener,
                itemScrollController: scrollController,
                itemCount: _filteredRules!.length,
                itemBuilder: (context, index) {
                  return RuleWidget(
                    model: _filteredRules![index],
                    callback: linkCallback,
                    shouldIndent: !_viewModel.isFiltered,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
