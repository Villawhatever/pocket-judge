import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_judge/card_search/card_search_viewmodel.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_viewmodel.dart';
import 'package:pocket_judge/errata/errata_viewmodel.dart';
import 'package:pocket_judge/preferences_state.dart';
import 'package:pocket_judge/simple_views/about_view.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:pocket_judge/utils/db.dart';
import 'package:pocket_judge/utils/extensions/context_extensions.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'constants.dart';
import 'firebase_options.dart';

void main() async {
  var binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initLocalStorage();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await _setupIsar();

  runApp(PocketJudge());
}

Future _setupIsar() async {
  final isarDbAsset = await getIsarDbAsset();

  final docDir = await getApplicationDocumentsDirectory();

  final localFile = File('${docDir.path}/pocket-judge.isar');
  final data = await rootBundle.load(isarDbAsset);
  await localFile.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}

class PocketJudge extends StatelessWidget {
  PocketJudge({super.key});

  final crVm = CoreRulesViewModel();
  final errataVm = ErrataViewModel();
  final searchVm = SearchViewModel();
  final trVm = TournamentRulesViewModel();

  Future<void> setupData() async {
    await Future.wait([
      crVm.load(),
      errataVm.load(),
      searchVm.load(),
      trVm.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PreferencesState()),
        ChangeNotifierProvider(create: (context) => crVm),
        ChangeNotifierProvider(create: (context) => errataVm),
        ChangeNotifierProvider(create: (context) => searchVm),
        ChangeNotifierProvider(create: (context) => trVm),
      ],
      builder: (context, _) {
        return SafeArea(
          top: false,
          bottom: true,
          child: MaterialApp(
            title: 'Pocket Judge',
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(
                    seedColor: const Color(0xff1d3143),
                    brightness: Brightness.dark,
                  ).copyWith(
                    primary: const Color(0xffbbcfdd),
                    inversePrimary: const Color(0xff1d3143),
                    secondary: const Color(0xffea7d24),
                    secondaryContainer: const Color(0x45ad9d69),
                    tertiary: const Color(0xff1b1b1b),
                    errorContainer: const Color(0x884f2714),
                    onError: Colors.black,
                  ),
              useMaterial3: true,
            ),
            builder: (context, child) {
              return Theme(
                data: context.theme.copyWith(
                  textTheme: TextTheme(
                    bodyLarge: TextStyle(
                      fontFamily: spiegel,
                      color: context.colorScheme.primary,
                    ),
                    bodyMedium: TextStyle(
                      fontFamily: spiegel,
                      color: context.colorScheme.primary,
                    ),
                    bodySmall: TextStyle(
                      fontFamily: spiegel,
                      color: context.colorScheme.primary,
                    ),
                    titleLarge: TextStyle(
                      fontFamily: beaufort,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.secondary,
                    ),
                    titleMedium: TextStyle(
                      fontFamily: beaufort,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.secondary,
                    ),
                    titleSmall: TextStyle(
                      fontFamily: beaufort,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ),
                child: child!,
              );
            },
            home: UpgradeAlert(
              upgrader: Upgrader(debugLogging: false),
              child: FutureBuilder(
                future: setupData()
                    .then((_) => FlutterNativeSplash.remove())
                    .catchError((_) => FlutterNativeSplash.remove()),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CoreRulesView(title: 'Core Rules');
                  } else if (snapshot.hasError) {
                    return AboutView(title: 'About');
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
