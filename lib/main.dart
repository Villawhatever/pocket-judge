import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/about/about_view.dart';
import 'package:pocket_judge/errata/errata_viewmodel.dart';
import 'package:pocket_judge/preferences_state.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_viewmodel.dart';
import 'package:pocket_judge/search/search_viewmodel.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
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

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({super.key});

  final crVm = CoreRulesViewModel();
  final errataVm = ErrataViewModel();
  final searchVm = SearchViewModel();
  final trVm = TournamentRulesViewModel();

  Future<void> setupData() async {
    await crVm.load();
    await errataVm.load();
    await searchVm.load();
    await trVm.load();
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1d3143),
                brightness: Brightness.dark,
              ).copyWith(
                primary: const Color(0xffbbcfdd),
                inversePrimary: const Color(0xff1d3143),
                secondary: const Color(0xffea7d24),
                tertiary: const Color(0xff1b1b1b),
                error: const Color(0xffcf6679),
                onError: Colors.black,
              ),
              useMaterial3: true,
            ),
            home: FutureBuilder(
              future: setupData().then((_) => FlutterNativeSplash.remove()),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CoreRulesView(title: 'Core Rules');
                } else {
                  return AboutView(title: 'About');
                }
              },
            ),
          ),
        );
      });
  }
}
