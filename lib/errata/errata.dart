import 'package:flutter/material.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'errata_viewmodel.dart';
import 'erratum.dart';
import 'erratum_widget.dart';

class ErrataView extends StatefulWidget {
  const ErrataView({super.key});

  @override
  State<ErrataView> createState() => ErrataViewState();
}

class ErrataViewState extends State<ErrataView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ErrataViewModel>(context, listen: true);
    final scrollController = ItemScrollController();

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

    final filteredErrata = context.select<ErrataViewModel, List<ErratumModel>>((vm) => vm.errata);

    return AppWrapper(
      title: searchBar,
      body: ScrollablePositionedList.separated(
        itemScrollController: scrollController,
        itemCount: filteredErrata.length,
        itemBuilder: (context, index) {
          return ErratumWidget(model: filteredErrata[index]);
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }
}
