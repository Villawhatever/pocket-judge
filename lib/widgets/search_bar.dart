import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    this.hintText,
    required this.textController,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final String? hintText;
  final TextEditingController textController;
  final Function? onChanged;
  final Function? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<CustomSearchBar> createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  late final _textController = widget.textController;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: widget.hintText,
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      onSubmitted: (value) => widget.onSubmitted?.call(value),
      backgroundColor: WidgetStateProperty.all(context.colorScheme.tertiary),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      trailing: [
        IconButton(
            icon: _textController.text.isEmpty
                ? Image.asset('lib/assets/img/search.png', width: 25)
                : Icon(Icons.clear,
                    size: 25, color: context.colorScheme.secondary),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                widget.onClear?.call();
                return;
              }
            }),
      ],
      controller: _textController,
    );
  }
}
