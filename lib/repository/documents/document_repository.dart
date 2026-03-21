// Notre fichier Repository Document abstrait
// (même pattern que UserRepository de référence)

import 'package:app_gestionsupportdecours/models/document_model.dart';

abstract class DocumentRepository {
  // On met Future pour faire appel à des sources externes

  Future<List<DocumentModel>>
      recupererTousDocuments(); // Retourner tous les documents

  Future<List<DocumentModel>> recupererDocumentsParClasse(
      String classe); // Filtrer par classe

  Future<List<DocumentModel>> recupererDocumentsParMatiere(
      String matiere); // Filtrer par matière

  Future<List<DocumentModel>> rechercherDocuments(
      String motCle); // Recherche par mot-clé

  Future<DocumentModel> recupererDocument(
      String id); // Récupérer un seul document

  Future<DocumentModel> ajouterDocument(
      DocumentModel document); // Ajouter un document (admin)

  Future<DocumentModel> modifierDocument(
      DocumentModel document); // Modifier un document (admin)

  Future<void> supprimerDocument(
      String id); // Supprimer un document (admin)
}
