import 'package:flutter/material.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
            title: const Text("Core Rules"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const CoreRulesView()
                ),
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
      ],
    ));
  }
}
