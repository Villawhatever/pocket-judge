import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:pocket_judge/card_search/card_search_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utils/extensions/context_extensions.dart';
import '../widgets/search_bar.dart';
import 'card.dart';
import 'card_widget.dart';

class CardSearchView extends StatefulWidget {
  const CardSearchView({super.key, required this.title});

  final String title;

  @override
  State<CardSearchView> createState() => _CardSearchViewState();
}

class _CardSearchViewState extends State<CardSearchView> {
  late TextEditingController _textController;
  late ItemScrollController _scrollController;

  late SearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ItemScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final item in _expansibleMap.values) {
      item.dispose();
    }
    _viewModel.reset();
    super.dispose();
  }

  final Map<CardModel, ExpansibleController> _expansibleMap = {};

  @override
  Widget build(BuildContext context) {
    _viewModel = Provider.of<SearchViewModel>(context, listen: true);

    clearSearch() {
      _textController.clear();
      _viewModel.search(null);
    }

    onSearchTextChanged(value) {
      setState(() {
        _textController.text = value;
      });
    }

    reset(String? value) {
      _viewModel.search(value);
      for (final exp in _expansibleMap.values) {
        exp.collapse();
      }
    }

    final searchBar = CustomSearchBar(
        textController: _textController,
        onChanged: onSearchTextChanged,
        onSubmitted: reset,
        onClear: clearSearch);

    final filteredCards =
        context.select<SearchViewModel, List<CardModel>>((vm) => vm.cards);
    Widget body;

    if (filteredCards.isEmpty) {
      body = SingleChildScrollView(
        child: Column(
          children: [
            MarkdownBody(
              data: _viewModel.searchSyntax,
              styleSheet: MarkdownStyleSheet.fromTheme(context.theme).copyWith(
                  code: TextStyle(color: context.colorScheme.secondary)),
            ),
          ],
        ),
      );
    } else {
      body = Padding(
          padding: EdgeInsetsGeometry.only(top: 7),
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 7),
            child: ScrollablePositionedList.separated(
              itemScrollController: _scrollController,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];

                _expansibleMap[card] ??= ExpansibleController();
                _expansibleMap[card]!.addListener(() {
                  _scrollController.jumpTo(index: index);
                });
                return CardWidget(
                    model: card, expansibleController: _expansibleMap[card]!);
              },
            ),
          ));
    }

    return AppWrapper(title: widget.title, searchBar: searchBar, body: body);
  }
}
