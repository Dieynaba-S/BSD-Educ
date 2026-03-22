
import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/firebase_options.dart';
import 'package:app_gestionsupportdecours/utils/routeur.dart';
import 'package:app_gestionsupportdecours/utils/theme_perso.dart';
import 'package:app_gestionsupportdecours/views/page_connexion.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AppState appState = AppState();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: const AppGestionSupportDeCours(),
    ),
  );
}

class AppGestionSupportDeCours extends StatelessWidget {
  const AppGestionSupportDeCours({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Définition de la route initiale
      initialRoute: Routeur.routeInitiale,
      routes: Routeur.route,
      onGenerateRoute: Routeur.onGenerateRoute,

      // Rediriger si route inconnue
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const PageConnexion(),
      ),

      // Langues
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Thèmes
      theme: ThemePerso.modeClair,
      darkTheme: ThemePerso.modeSombre,
      themeMode: AppState().themeChoisi ?? ThemeMode.system,
    );
  }
}