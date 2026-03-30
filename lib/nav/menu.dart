import 'package:flutter/material.dart';
import 'package:pocket_judge/errata/errata_view.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';

import '../simple_views/about_view.dart';
import '../constants.dart';
import '../search/search_view.dart';
import '../utils/extensions/context_extensions.dart';

class LinkGenerator {
  const LinkGenerator({
    required this.name,
    required this.img,
    required this.view
  });

  final String name;
  final String img;
  final Widget view;
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    var linkBuilders = [
      LinkGenerator(
        name:'Core Rules',
        img: 'lib/assets/img/core_rules.png',
        view: CoreRulesView(title: 'Core Rules')
      ),
      LinkGenerator(
        name:'Tournament Rules',
        img: 'lib/assets/img/tournament_rules.png',
        view: TournamentRulesView(title: 'Tournament Rules')
      ),
      LinkGenerator(
        name:'Card Search',
        img: 'lib/assets/img/card_search.png',
        view: SearchView(title: 'Card Search')
      ),
      LinkGenerator(
        name:'Card Specific Notes',
        img: 'lib/assets/img/card_notes.png',
        view: ErrataView(title: 'Card Specific Notes')
      ),
      LinkGenerator(
        name:'About',
        img: 'lib/assets/img/about.png',
        view: AboutView(title: 'About')
      ),
    ];

    var links = [];
    for (final item in linkBuilders) {
      links.add(ListTile(
        leading: item.name == 'Card Specific Notes' ? Transform.translate(
          offset: Offset(2, 0),
          child: Image.asset(item.img, width: 32, height: 32),
        ) : Image.asset(item.img, width: 32, height: 32),
        title: Text(item.name.toUpperCase(), style: TextStyle(color: context.colorScheme.secondary, fontFamily: Fonts.beaufort, fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => item.view),
          );
        })
      );
    }

    return Drawer(
      child: ListView(
        padding: MediaQuery.of(context).viewPadding,
        children: [
          ...links
        ],
      )
    );
  }
}
