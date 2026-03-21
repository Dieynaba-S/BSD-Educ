// Création de notre classe abstraite avec la constante de route initiale
// (même pattern que Routeur de référence)

import 'package:flutter/material.dart';
import 'package:app_gestionsupportdecours/views/page_accueil.dart';
import 'package:app_gestionsupportdecours/views/page_connexion.dart';
import 'package:app_gestionsupportdecours/views/page_inscription.dart';
import 'package:app_gestionsupportdecours/views/page_documents.dart';
import 'package:app_gestionsupportdecours/views/page_detail_document.dart';
import 'package:app_gestionsupportdecours/views/page_profil.dart';
import 'package:app_gestionsupportdecours/views/page_admin.dart';
import 'package:app_gestionsupportdecours/models/document_model.dart';

abstract class Routeur {
  static const String routeInitiale = '/page-connexion';

  static final Map<String, WidgetBuilder> route = {
    routeInitiale:          (context) => const PageConnexion(),
    '/page-inscription':    (context) => const PageInscription(),
    '/page-accueil':        (context) => const PageAccueil(),
    '/page-documents':      (context) => const PageDocuments(),
    '/page-profil':         (context) => const PageProfil(),
    '/page-admin':          (context) => const PageAdmin(),
  };

  // Route avec paramètre pour passer un DocumentModel
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/page-detail-document') {
      final document = settings.arguments as DocumentModel;
      return MaterialPageRoute(
        builder: (context) => PageDetailDocument(document: document),
      );
    }
    return MaterialPageRoute(builder: (context) => const PageConnexion());
  }
}
