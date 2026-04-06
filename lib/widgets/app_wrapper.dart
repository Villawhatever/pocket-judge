import 'package:flutter/material.dart';

import '../nav/menu.dart';
import '../utils/extensions/context_extensions.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper(
      {super.key,
      required this.title,
      required this.body,
      this.searchBar,
      this.endDrawer});

  final String title;
  final Widget body;
  final Widget? searchBar;
  final Widget? endDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Menu(),
      endDrawer: endDrawer,
      appBar: AppBar(
          centerTitle: true,
          title: Text(title.toUpperCase(), style: context.textTheme.titleLarge),
          automaticallyImplyActions: false,
          foregroundColor: context.colorScheme.primary,
          backgroundColor: context.colorScheme.inversePrimary,
          iconTheme: IconThemeData(
            color: context.colorScheme.secondary,
          ),
          leading: Builder(builder: (context) {
            return IconButton(
                icon: Image.asset('lib/assets/img/menu.png', width: 25),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                });
          }),
          scrolledUnderElevation: 0,
          actions: [
            Builder(builder: (context) {
              if (endDrawer != null) {
                return IconButton(
                    icon: Image.asset('lib/assets/img/index.png', width: 25),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    });
              }
              return SizedBox.shrink();
            })
          ]),
      body: Column(children: [
        if (searchBar != null)
          Container(
            color: context.colorScheme.inversePrimary,
            height: 55,
            child: Row(children: [
              Expanded(
                child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(5, 0, 5, 10),
                    child: searchBar!),
              )
            ]),
          ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5), child: body),
        ),
      ]),
    );
  }
}
