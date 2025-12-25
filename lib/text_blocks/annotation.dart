import 'package:flutter/cupertino.dart';

class Annotation extends StatelessWidget {
  const Annotation({super.key, required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return isEnabled ? const Text("Visible!") : const SizedBox.shrink();
  }
}
