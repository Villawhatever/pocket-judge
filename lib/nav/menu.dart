import 'package:flutter/material.dart';
import 'package:pocket_judge/errata/errata.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';

import '../about/about_view.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: MediaQuery.of(context).viewPadding,
      children: [
        ListTile(
            title: const Text("Core Rules"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CoreRulesView()),
              );
            }),
        ListTile(
            title: const Text("Tournament Rules"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const TournamentRulesView()),
              );
            }),
        ListTile(
            title: const Text("Errata/FAQs"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ErrataView()),
              );
            }),
        const Divider(
            height: 25,
            thickness: 3,
            indent: 25,
            endIndent: 25,
            color: Colors.white),
        ListTile(
            title: const Text("About/Legal"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AboutView()),
              );
            }),
      ],
    ));
  }
}
