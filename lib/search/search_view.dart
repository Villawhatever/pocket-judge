import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:pocket_judge/search/search_viewmodel.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'card.dart';
import 'card_widget.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  final _textController = TextEditingController();
  final Future<String> _markdownData = rootBundle.loadString('lib/assets/search_syntax.md');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<SearchViewModel>(context, listen: true);
    final scrollController = ItemScrollController();

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    final searchBar = SearchBar(
      hintText: "[Search]",
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
                })),
      ],
      controller: _textController,
    );

    final filteredCards = context
        .select<SearchViewModel, List<CardModel>>((vm) => vm.cards);

    Widget body;

    if (filteredCards.isEmpty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _markdownData,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              List<Widget> children = [];
              if (snapshot.hasData) {
                children = [Flexible(
                  fit: FlexFit.loose,
                  child: MarkdownBody(
                    data: snapshot.data!,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      code: TextStyle(
                        color: Theme.of(context).colorScheme.secondary
                      )
                    ),
                  ),
                )];
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            }
          ),
        ],
      );
    } else {
      body = ScrollablePositionedList.separated(
        itemScrollController: scrollController,
        itemCount: filteredCards.length,
        itemBuilder: (context, index) {
          return CardWidget(
              model: filteredCards[index]);
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    }

    return AppWrapper(
      title: searchBar,
      body: body
    );
  }
}
