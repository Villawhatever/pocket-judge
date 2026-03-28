import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_wrapper.dart';

class VersionInfo {
  final String version;
  final String buildNumber;

  VersionInfo(
    this.version,
    this.buildNumber
  );
}

class AboutView extends StatelessWidget {
  const AboutView({super.key, required this.title});

  final String title;

  Future<VersionInfo> _fetchPackageInfo() async {
    var info = await PackageInfo.fromPlatform();
    return VersionInfo(info.version, info.buildNumber);
  }
  @override
  Widget build(BuildContext context) {
    final Uri githubUri = Uri.parse('https://github.com/Villawhatever/pocket-judge');
    final Uri discordUri = Uri.parse('https://discord.com/channels/@me/49416803398455296');

    return AppWrapper(
        title: 'About',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pocket Judge', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontFamily: 'Beaufort', fontWeight: FontWeight.bold, fontSize: 24)),
            Text(
                'Built by Villa and Tobias Vyseri',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            FutureBuilder<VersionInfo>(
              future: _fetchPackageInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RichText(
                    text: TextSpan(
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      children: [
                        TextSpan(text: 'Version ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '${snapshot.data!.version} (build# ${snapshot.data!.buildNumber})')
                      ]
                    ),
                  );
                }
                return Text('');
              }
            ),
            Text(
                'For feedback, feature requests, or bug reports, please contact @villawhatever on Discord or open an issue on Github.',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      launchUrl(githubUri);
                    },
                    child: FaIcon(FontAwesomeIcons.github,
                        color: Theme.of(context).colorScheme.primary, size: 25),
                  ),
                  TextButton(
                    onPressed: () async {
                      launchUrl(discordUri);
                    },
                    child: FaIcon(FontAwesomeIcons.discord,
                        color: Theme.of(context).colorScheme.primary, size: 25),
                  ),
                ]
            ),
            Text('Pocket Judge will never collect any personal information for any reason.'),
            Text('This app is not produced by or affiliated with Riot Games, Riftbound, Tencent, or any related entities. All card images remain the copyright of Riot Games. All rules, guides, card information, etc are published by Riot Games.')

        ]));
  }
}
