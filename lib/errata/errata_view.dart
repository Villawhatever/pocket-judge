import 'package:flutter/material.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../widgets/search.dart';
import 'errata_viewmodel.dart';
import 'erratum.dart';
import 'erratum_widget.dart';

class ErrataView extends StatefulWidget {
  const ErrataView({super.key, required this.title});

  final String title;
  @override
  State<ErrataView> createState() => ErrataViewState();
}

class ErrataViewState extends State<ErrataView> {
  final _textController = TextEditingController();
  late ErrataViewModel viewModel;

  @override
  void dispose() {
    _textController.dispose();
    viewModel.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ErrataViewModel>(context, listen: true);
    final scrollController = ItemScrollController();

    clearSearch() {
      _textController.clear();
      viewModel.search(null);
    }

    final searchBar = CustomSearchBar(
        textController: _textController,
        onChanged: viewModel.search,
        onSubmitted: viewModel.search,
        onClear: clearSearch);

    final filteredErrata =
        context.select<ErrataViewModel, List<ErratumModel>>((vm) => vm.errata);

    return AppWrapper(
      title: 'Card Specific Notes',
      searchBar: searchBar,
      body: ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemCount: filteredErrata.length,
        itemBuilder: (context, index) {
          return ErratumWidget(model: filteredErrata[index]);
        },
      ),
    );
  }
}
