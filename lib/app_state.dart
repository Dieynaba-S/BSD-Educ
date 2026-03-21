// Gestion d'état global avec Provider (pattern Singleton identique au projet de référence)
// Ce fichier contient toutes les variables utilisables partout dans l'application

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final AppState _singleton = AppState._internal();
  AppState._internal();
  factory AppState() => _singleton;

  // ── Variables globales ───────────────────────────────────────────────────
  ThemeMode? themeChoisi;
  bool estConnecte = false;
  String? utilisateurConnecteUid;

  // ── Notifier tous les Widgets abonnés ────────────────────────────────────
  void update(VoidCallback callback) {
    callback();
    notifyListeners(); // Rebuilder toutes les pages abonnées
  }
}
