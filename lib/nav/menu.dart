import 'package:flutter/material.dart';
import 'package:pocket_judge/errata/errata_view.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';

import '../about/about_view.dart';
import '../search/search_view.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontFamily: 'Beaufort',
      fontWeight: FontWeight.bold
    );

    final String crTitle = 'Core Rules';
    final String trTitle = 'Tournament Rules';
    final String searchTitle = 'Card Search';
    final String errataTitle = 'Card Specific Notes';
    final String aboutTitle = 'About';

    return Drawer(
      child: ListView(
        padding: MediaQuery.of(context).viewPadding,
        children: [
          ListTile(
            title: Text(crTitle.toUpperCase(), style: style),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CoreRulesView(title: crTitle)),
              );
            }),
          ListTile(
            title: Text(trTitle.toUpperCase(), style: style),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TournamentRulesView(title: trTitle)),
              );
            }),
          ListTile(
            title: Text(searchTitle.toUpperCase(), style: style),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SearchView(title: searchTitle)),
              );
            }),
          ListTile(
            title: Text(errataTitle.toUpperCase(), style: style),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ErrataView(title: errataTitle)),
              );
            }),
          ListTile(
            title: Text(aboutTitle.toUpperCase(), style: style),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AboutView(title: aboutTitle)),
              );
            }),
        ],
      )
    );
  }
}
