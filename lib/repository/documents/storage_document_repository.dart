// Service upload Firebase Storage

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_gestionsupportdecours/dto/document_dto.dart';
import 'package:app_gestionsupportdecours/models/document_model.dart';

class StorageDocumentRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'documents';

  // Upload PDF vers Firebase Storage
  Future<String> uploaderFichier({
    required Uint8List fichierBytes,
    required String fichierNom,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('documents')
          .child('${DateTime.now().millisecondsSinceEpoch}_$fichierNom');

      final uploadTask = ref.putData(
        fichierBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Erreur upload : $e");
      rethrow;
    }
  }

  // Enregistrer le document dans Firestore
  Future<DocumentModel> enregistrerDocument({
    required String titre,
    required String description,
    required String matiere,
    required String classe,
    required String annee,
    required String type,
    required String fichierUrl,
    required String fichierNom,
    required String uploadePar,
  }) async {
    try {
      DocumentDto dto = DocumentDto(
        id: '',
        titre: titre,
        description: description,
        matiere: matiere,
        classe: classe,
        annee: annee,
        type: type,
        fichierUrl: fichierUrl,
        fichierNom: fichierNom,
        uploadePar: uploadePar,
        dateCreation: DateTime.now().toIso8601String(),
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(dto.toJson());

      return DocumentModel(
        id: docRef.id,
        titre: titre,
        description: description,
        matiere: matiere,
        classe: classe,
        annee: annee,
        type: type,
        fichierUrl: fichierUrl,
        fichierNom: fichierNom,
        uploadePar: uploadePar,
        dateCreation: DateTime.now(),
      );
    } catch (e) {
      print("Erreur enregistrement : $e");
      rethrow;
    }
  }
}
