// Implémentation Firestore du DocumentRepository
// (même pattern que FirestoreUserRepository de référence)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_gestionsupportdecours/dto/document_dto.dart';
import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:app_gestionsupportdecours/repository/documents/document_repository.dart';

class FirestoreDocumentRepository implements DocumentRepository {
  static const String _collection = 'documents';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Méthode privée : DTO → MODEL ──────────────────────────────────────────

  DocumentModel _dtoVersModel(DocumentDto dto) {
    return DocumentModel(
      id: dto.id,
      titre: dto.titre,
      description: dto.description,
      matiere: dto.matiere,
      classe: dto.classe,
      annee: dto.annee,
      type: dto.type,
      fichierUrl: dto.fichierUrl,
      fichierNom: dto.fichierNom,
      uploadePar: dto.uploadePar,
      dateCreation: DateTime.tryParse(dto.dateCreation) ?? DateTime.now(),
    );
  }

  @override
  Future<List<DocumentModel>> recupererTousDocuments() async {
    List<DocumentModel> documents = [];
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('dateCreation', descending: true)
          .get();

      documents = snapshot.docs.map((doc) {
        // a- Convertir en DTO
        DocumentDto dto = DocumentDto.fromJson(doc.data(), doc.id);
        // b- Convertir le DTO en MODEL
        return _dtoVersModel(dto);
      }).toList();

      return documents;
    } catch (e) {
      print("Erreur récupération documents : $e");
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> recupererDocumentsParClasse(
      String classe) async {
    List<DocumentModel> documents = [];
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('classe', isEqualTo: classe)
          .orderBy('dateCreation', descending: true)
          .get();

      documents = snapshot.docs.map((doc) {
        DocumentDto dto = DocumentDto.fromJson(doc.data(), doc.id);
        return _dtoVersModel(dto);
      }).toList();

      return documents;
    } catch (e) {
      print("Erreur récupération par classe : $e");
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> recupererDocumentsParMatiere(
      String matiere) async {
    List<DocumentModel> documents = [];
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('matiere', isEqualTo: matiere)
          .orderBy('dateCreation', descending: true)
          .get();

      documents = snapshot.docs.map((doc) {
        DocumentDto dto = DocumentDto.fromJson(doc.data(), doc.id);
        return _dtoVersModel(dto);
      }).toList();

      return documents;
    } catch (e) {
      print("Erreur récupération par matière : $e");
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> rechercherDocuments(String motCle) async {
    // Firestore ne supporte pas la recherche full-text nativement
    // On récupère tout et on filtre côté client
    try {
      final tousDocuments = await recupererTousDocuments();
      final motCleMin = motCle.toLowerCase();

      return tousDocuments.where((doc) {
        return doc.titre.toLowerCase().contains(motCleMin) ||
            doc.description.toLowerCase().contains(motCleMin) ||
            doc.matiere.toLowerCase().contains(motCleMin);
      }).toList();
    } catch (e) {
      print("Erreur recherche documents : $e");
      rethrow;
    }
  }

  @override
  Future<DocumentModel> recupererDocument(String id) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        throw Exception("Document introuvable");
      }

      DocumentDto dto = DocumentDto.fromJson(doc.data()!, doc.id);
      return _dtoVersModel(dto);
    } catch (e) {
      print("Erreur récupération document : $e");
      rethrow;
    }
  }

  @override
  Future<DocumentModel> ajouterDocument(DocumentModel document) async {
    try {
      DocumentDto dto = DocumentDto(
        id: document.id,
        titre: document.titre,
        description: document.description,
        matiere: document.matiere,
        classe: document.classe,
        annee: document.annee,
        type: document.type,
        fichierUrl: document.fichierUrl,
        fichierNom: document.fichierNom,
        uploadePar: document.uploadePar,
        dateCreation: document.dateCreation.toIso8601String(),
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(dto.toJson());

      // Retourner le document avec son ID généré par Firestore
      return DocumentModel(
        id: docRef.id,
        titre: document.titre,
        description: document.description,
        matiere: document.matiere,
        classe: document.classe,
        annee: document.annee,
        type: document.type,
        fichierUrl: document.fichierUrl,
        fichierNom: document.fichierNom,
        uploadePar: document.uploadePar,
        dateCreation: document.dateCreation,
      );
    } catch (e) {
      print("Erreur ajout document : $e");
      rethrow;
    }
  }

  @override
  Future<DocumentModel> modifierDocument(DocumentModel document) async {
    try {
      DocumentDto dto = DocumentDto(
        id: document.id,
        titre: document.titre,
        description: document.description,
        matiere: document.matiere,
        classe: document.classe,
        annee: document.annee,
        type: document.type,
        fichierUrl: document.fichierUrl,
        fichierNom: document.fichierNom,
        uploadePar: document.uploadePar,
        dateCreation: document.dateCreation.toIso8601String(),
      );

      await _firestore
          .collection(_collection)
          .doc(document.id)
          .update(dto.toJson());

      return document;
    } catch (e) {
      print("Erreur modification document : $e");
      rethrow;
    }
  }

  @override
  Future<void> supprimerDocument(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print("Erreur suppression document : $e");
      rethrow;
    }
  }
}
