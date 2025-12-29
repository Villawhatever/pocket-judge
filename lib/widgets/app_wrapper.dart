import 'package:flutter/material.dart';

import '../nav/menu.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key, required this.title, required this.body});

  final Widget title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Menu(),
      appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: title
      ),
      body: body
    );
  }
}