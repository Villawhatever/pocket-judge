import 'package:flutter/material.dart';

import '../nav/menu.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key, required this.title, required this.body, this.searchBar});

  final String title;
  final Widget body;
  final Widget? searchBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Menu(),
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        scrolledUnderElevation: 0,
        title: Text(title.toUpperCase(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Beaufort',
            fontWeight: FontWeight.bold)
        ),
      ),
      body: Column(
        children: [
          if (searchBar != null)
            Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              height: 55,
              child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(5, 0, 5, 10),
                          child: searchBar!
                        ),
                    )
                  ]
              ),
            ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 5, 12, 5), child: body
            ),
          ),
        ]
      ),
    );
  }
}
