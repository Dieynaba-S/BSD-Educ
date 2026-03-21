// Notre fichier Repository Utilisateur abstrait
// (même pattern que UserRepository de référence)

import 'package:app_gestionsupportdecours/models/user_model.dart';

abstract class UserRepository {
  // On met Future pour faire appel à des sources externes

  Future<UserModel> connexion(
      String email, String motDePasse); // Connecter un utilisateur

  Future<UserModel> inscription({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String classe,
    required String annee,
    required String motDePasse,
  }); // Inscrire un nouvel utilisateur

  Future<void> deconnexion(); // Déconnecter l'utilisateur

  Future<void> reinitialiserMotDePasse(
      String email); // Réinitialiser le mot de passe

  Future<UserModel?> recupererUtilisateur(
      String uid); // Récupérer un utilisateur par son uid

  Future<List<UserModel>>
      recupererTousUtilisateurs(); // Récupérer tous les utilisateurs (admin)

  Future<UserModel> modifierUtilisateur(
      UserModel utilisateur); // Modifier un utilisateur

  Future<void> supprimerUtilisateur(
      String uid); // Supprimer un utilisateur (admin)
}
