import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pocket_judge/errata/errata_viewmodel.dart';
import 'package:pocket_judge/preferences_state.dart';
import 'package:pocket_judge/core_rules/core_rules_view.dart';
import 'package:pocket_judge/core_rules/core_rules_viewmodel.dart';
import 'package:pocket_judge/tournament_rules/tournament_rules_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PreferencesState()),
          ChangeNotifierProvider(create: (context) => CoreRulesViewModel()),
          ChangeNotifierProvider(
              create: (context) => TournamentRulesViewModel()),
          ChangeNotifierProvider(create: (context) => ErrataViewModel())
        ],
        builder: (context, _) {
          return SafeArea(
            top: false,
            bottom: true,
            child: MaterialApp(
              title: 'Pocket Judge',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff1a283f),
                  brightness: Brightness.dark,
                ).copyWith(
                  primaryContainer: const Color(0xff1a283f),
                  inversePrimary: const Color(0xff1a283f),
                  secondary: const Color(0xffe48632),
                  onSecondaryContainer: Colors.black,
                  error: const Color(0xffcf6679),
                  onError: Colors.black,
                ),
                useMaterial3: true,
              ),
              home: const CoreRulesView(),
            ),
          );
        });
  }
}
