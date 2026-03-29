import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:pocket_judge/search/search_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utils/extensions/context_extensions.dart';
import '../widgets/search.dart';
import 'card.dart';
import 'card_widget.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.title});

  final String title;

  @override
  State<SearchView> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  final _textController = TextEditingController();
  late SearchViewModel viewModel;

  @override
  void dispose() {
    _textController.dispose();
    viewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<SearchViewModel>(context, listen: true);
    final scrollController = ItemScrollController();

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    onSearchTextChanged(value) {
      setState(() {
        _textController.text = value;
      });
    }

    final searchBar = CustomSearchBar(
      textController: _textController,
      onChanged: onSearchTextChanged,
      onSubmitted: viewModel.search,
      onClear: clearSearch
    );

    final filteredCards =
      context.select<SearchViewModel, List<CardModel>>((vm) => vm.cards);

    Widget body;

    if (filteredCards.isEmpty) {
      body = SingleChildScrollView(
        child: Column(
          children: [
            MarkdownBody(
              data: viewModel.searchSyntax,
              styleSheet:
              MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                code: TextStyle(
                  color: context.colorScheme.secondary
                )
              ),
            ),
          ],
        ),
      );
    } else {
      body = ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemCount: filteredCards.length,
        itemBuilder: (context, index) {
          return CardWidget(model: filteredCards[index]);
        },
      );
    }

    return AppWrapper(title: 'Card Search', searchBar: searchBar, body: body);
  }
}
