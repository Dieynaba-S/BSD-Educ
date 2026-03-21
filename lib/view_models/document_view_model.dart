// Notre DocumentViewModel (même pattern que UserViewModel de référence)
// Gestion de l'état documents : chargement, recherche, filtres

import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:app_gestionsupportdecours/repository/documents/document_repository.dart';

class DocumentViewModel {
  final DocumentRepository repository; // Principe de Polymorphisme

  DocumentViewModel(this.repository);

  // ── Variables d'état ─────────────────────────────────────────────────────

  List<DocumentModel> documents = [];        // Tous les documents chargés
  List<DocumentModel> documentsFiltres = []; // Résultats de la recherche
  DocumentModel? documentSelectionne;        // Document affiché en détail

  String? erreur;
  bool isLoading = false;
  String filtreClasse = '';   // Filtre actif par classe
  String filtreMatiere = '';  // Filtre actif par matière
  String motCleRecherche = ''; // Recherche active

  // ── Chargement de tous les documents ─────────────────────────────────────

  Future<void> chargementDocuments() async {
    erreur = null;
    isLoading = true;

    try {
      documents = await repository.recupererTousDocuments();
      documentsFiltres = List.from(documents); // Copie pour le filtre
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Chargement par classe ─────────────────────────────────────────────────

  Future<void> chargementDocumentsParClasse(String classe) async {
    erreur = null;
    isLoading = true;
    filtreClasse = classe;

    try {
      documents = await repository.recupererDocumentsParClasse(classe);
      documentsFiltres = List.from(documents);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Chargement par matière ────────────────────────────────────────────────

  Future<void> chargementDocumentsParMatiere(String matiere) async {
    erreur = null;
    isLoading = true;
    filtreMatiere = matiere;

    try {
      documents = await repository.recupererDocumentsParMatiere(matiere);
      documentsFiltres = List.from(documents);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Recherche par mot-clé ─────────────────────────────────────────────────

  Future<void> rechercherDocuments(String motCle) async {
    erreur = null;
    isLoading = true;
    motCleRecherche = motCle;

    try {
      if (motCle.trim().isEmpty) {
        documentsFiltres = List.from(documents);
      } else {
        documentsFiltres = await repository.rechercherDocuments(motCle);
      }
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Sélectionner un document ──────────────────────────────────────────────

  void selectionnerDocument(DocumentModel document) {
    documentSelectionne = document;
  }

  // ── Ajouter un document (admin) ───────────────────────────────────────────

  Future<void> ajouterDocument(DocumentModel document) async {
    erreur = null;
    isLoading = true;

    try {
      final nouveau = await repository.ajouterDocument(document);
      documents.insert(0, nouveau);
      documentsFiltres.insert(0, nouveau);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Supprimer un document (admin) ─────────────────────────────────────────

  Future<void> supprimerDocument(String id) async {
    erreur = null;
    isLoading = true;

    try {
      await repository.supprimerDocument(id);
      documents.removeWhere((doc) => doc.id == id);
      documentsFiltres.removeWhere((doc) => doc.id == id);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Réinitialiser les filtres ─────────────────────────────────────────────

  void reinitialiserFiltres() {
    documentsFiltres = List.from(documents);
    filtreClasse = '';
    filtreMatiere = '';
    motCleRecherche = '';
  }
}
