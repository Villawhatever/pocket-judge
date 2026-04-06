import 'package:flutter/material.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';
import 'package:provider/provider.dart';

import '../widgets/search_bar.dart';
import 'errata_viewmodel.dart';
import 'erratum.dart';
import 'erratum_widget.dart';

class ErrataView extends StatefulWidget {
  const ErrataView({super.key, required this.title});

  final String title;
  @override
  State<ErrataView> createState() => _ErrataViewState();
}

class _ErrataViewState extends State<ErrataView> {
  final _textController = TextEditingController();
  late ErrataViewModel _viewModel;

  @override
  void dispose() {
    _viewModel.reset();
    for (var exp in _expansibleMap.values) {
      exp.dispose();
    }
    super.dispose();
  }

  final Map<ErratumModel, ExpansibleController> _expansibleMap = {};

  @override
  Widget build(BuildContext context) {
    _viewModel = Provider.of<ErrataViewModel>(context, listen: true);

    collapseAll() {
      for (var exp in _expansibleMap.values) {
        exp.collapse();
      }
    }

    clearSearch() {
      _textController.clear();
      collapseAll();
      _viewModel.search(null);
    }

    onChanged(String? value) {
      collapseAll();
      _viewModel.search(value);
    }

    final searchBar = CustomSearchBar(
        textController: _textController,
        onChanged: onChanged,
        onSubmitted: _viewModel.search,
        onClear: clearSearch);

    final filteredErrata =
        context.select<ErrataViewModel, List<ErratumModel>>((vm) => vm.errata);

    return AppWrapper(
        title: widget.title,
        searchBar: searchBar,
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 7),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: filteredErrata.length,
            itemBuilder: (context, index) {
              _expansibleMap[filteredErrata[index]] ??= ExpansibleController();
              return ErratumWidget(
                  model: filteredErrata[index],
                  expansibleController: _expansibleMap[filteredErrata[index]]!);
            },
          ),
        ));
  }
}
