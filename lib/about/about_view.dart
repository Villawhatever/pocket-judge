import 'package:flutter/material.dart';

import '../widgets/app_wrapper.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});


  @override
  Widget build(BuildContext context) {
    return AppWrapper(
      title: const Text('About / Legal Stuff'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
        child: Text(
          'Pocket Judge ("we") will never collect any of your information for any reason. We are not affiliated with Riot Games, Riftbound, Tencent, or any related entities in any way.',
          style: TextStyle(color: Theme.of(context).colorScheme.primary)
        ),
      ),
    );
  }
}