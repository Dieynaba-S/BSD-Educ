// Implémentation Firestore du UserRepository
// (même pattern que FirestoreUserRepository de référence)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_gestionsupportdecours/dto/user_dto.dart';
import 'package:app_gestionsupportdecours/models/user_model.dart';
import 'package:app_gestionsupportdecours/repository/users/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  static const String _collection = 'utilisateurs';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> connexion(String email, String motDePasse) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );

      final doc = await _firestore
          .collection(_collection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception("Profil utilisateur introuvable");
      }

      // a- Convertir les données Firestore en DTO
      UserDto dto = UserDto.fromJson(doc.data()!, credential.user!.uid);

      // b- Convertir le DTO en MODEL
      UserModel utilisateur = UserModel(
        uid: dto.uid,
        prenom: dto.prenom,
        nom: dto.nom,
        email: dto.email,
        telephone: dto.telephone,
        classe: dto.classe,
        annee: dto.annee,
        role: dto.role,
      );

      return utilisateur;
    } catch (e) {
      print("Erreur de connexion : $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> inscription({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String classe,
    required String annee,
    required String motDePasse,
  }) async {
    try {
      // 1. Créer le compte Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );

      final uid = credential.user!.uid;

      // 2. Construire le DTO
      UserDto dto = UserDto(
        uid: uid,
        prenom: prenom.trim(),
        nom: nom.trim(),
        email: email.trim(),
        telephone: telephone.trim(),
        classe: classe.trim(),
        annee: annee.trim(),
        role: 'etudiant',
      );

      // 3. Enregistrer dans Firestore via le DTO
      await _firestore.collection(_collection).doc(uid).set(dto.toJson());

      // 4. Convertir le DTO en MODEL et retourner
      UserModel utilisateur = UserModel(
        uid: dto.uid,
        prenom: dto.prenom,
        nom: dto.nom,
        email: dto.email,
        telephone: dto.telephone,
        classe: dto.classe,
        annee: dto.annee,
        role: dto.role,
      );

      return utilisateur;
    } catch (e) {
      print("Erreur d'inscription : $e");
      rethrow;
    }
  }

  @override
  Future<void> deconnexion() async {
    await _auth.signOut();
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print("Erreur réinitialisation : $e");
      rethrow;
    }
  }

  @override
  Future<UserModel?> recupererUtilisateur(String uid) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(uid).get();

      if (!doc.exists) return null;

      // a- DTO
      UserDto dto = UserDto.fromJson(doc.data()!, uid);

      // b- MODEL
      return UserModel(
        uid: dto.uid,
        prenom: dto.prenom,
        nom: dto.nom,
        email: dto.email,
        telephone: dto.telephone,
        classe: dto.classe,
        annee: dto.annee,
        role: dto.role,
      );
    } catch (e) {
      print("Erreur récupération utilisateur : $e");
      return null;
    }
  }

  @override
  Future<List<UserModel>> recupererTousUtilisateurs() async {
    List<UserModel> utilisateurs = [];
    try {
      final snapshot = await _firestore.collection(_collection).get();

      utilisateurs = snapshot.docs.map((doc) {
        // a- DTO
        UserDto dto = UserDto.fromJson(doc.data(), doc.id);

        // b- MODEL
        return UserModel(
          uid: dto.uid,
          prenom: dto.prenom,
          nom: dto.nom,
          email: dto.email,
          telephone: dto.telephone,
          classe: dto.classe,
          annee: dto.annee,
          role: dto.role,
        );
      }).toList();

      return utilisateurs;
    } catch (e) {
      print("Erreur récupération utilisateurs : $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> modifierUtilisateur(UserModel utilisateur) async {
    try {
      UserDto dto = UserDto(
        uid: utilisateur.uid,
        prenom: utilisateur.prenom,
        nom: utilisateur.nom,
        email: utilisateur.email,
        telephone: utilisateur.telephone,
        classe: utilisateur.classe,
        annee: utilisateur.annee,
        role: utilisateur.role,
      );

      await _firestore
          .collection(_collection)
          .doc(utilisateur.uid)
          .update(dto.toJson());

      return utilisateur;
    } catch (e) {
      print("Erreur modification utilisateur : $e");
      rethrow;
    }
  }

  @override
  Future<void> supprimerUtilisateur(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      print("Erreur suppression utilisateur : $e");
      rethrow;
    }
  }
}
