import 'package:flutter/material.dart';
import 'package:pocket_judge/preferences_state.dart';
import 'package:provider/provider.dart';

class AnnotationsToggle extends StatefulWidget {
  const AnnotationsToggle({super.key, required this.isEnabled});
  final bool isEnabled;

  @override
  State<AnnotationsToggle> createState() => _AnnotationsToggleState();
}

class _AnnotationsToggleState extends State<AnnotationsToggle> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        title: const Text("Enable Annotations"),
        onChanged: (bool value) {
          setState(() {
            context.watch<PreferencesState>().setIsAnnotationsEnabled(value);
          });
        },
        value: widget.isEnabled);
  }
}
