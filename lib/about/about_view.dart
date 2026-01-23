import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_wrapper.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri url = Uri.parse('https://github.com/Villawhatever/pocket-judge');

    return AppWrapper(
        title: const Text('About / Legal Stuff'),
        body: Column(children: [
          Text(
              'Pocket Judge ("we") will never collect any of your information for any reason. We are not affiliated with Riot Games, Riftbound, Tencent, or any related entities in any way.\n\nFor any feedback, feature requests, bugs, and so on, please contact villawhatever on Discord OR open an issue on GitHub.',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          TextButton(
            onPressed: () async {
              launchUrl(url);
            },
            child: FaIcon(FontAwesomeIcons.github,
                color: Theme.of(context).colorScheme.primary, size: 100),
          ),
        ]));
  }
}
