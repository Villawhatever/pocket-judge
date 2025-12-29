import 'package:flutter/material.dart';

import '../widgets/app_wrapper.dart';

class TournamentRulesView extends StatelessWidget {
  const TournamentRulesView({super.key, required this.title});

  final Text title;

  @override
  Widget build(BuildContext context) {
    return AppWrapper(
      title: const Text("Tournament Rules"),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Text("Blah Blah")
      )
    );
  }
}
