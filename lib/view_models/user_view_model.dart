// Notre UserViewModel (même pattern que UserViewModel de référence)
// Gestion de l'état utilisateur : connexion, inscription, déconnexion

import 'package:app_gestionsupportdecours/models/user_model.dart';
import 'package:app_gestionsupportdecours/repository/users/user_repository.dart';

class UserViewModel {
  final UserRepository repository; // Principe de Polymorphisme

  UserViewModel(this.repository);

  // ── Variables d'état ─────────────────────────────────────────────────────

  UserModel? utilisateurConnecte; // L'utilisateur actuellement connecté
  List<UserModel> tousUtilisateurs = []; // Pour l'admin

  String? erreur;
  bool isLoading = false;

  // ── Connexion ─────────────────────────────────────────────────────────────

  Future<void> connexion(String email, String motDePasse) async {
    erreur = null;
    isLoading = true;

    try {
      utilisateurConnecte =
          await repository.connexion(email, motDePasse);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Inscription ───────────────────────────────────────────────────────────

  Future<void> inscription({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String classe,
    required String annee,
    required String motDePasse,
  }) async {
    erreur = null;
    isLoading = true;

    try {
      utilisateurConnecte = await repository.inscription(
        prenom: prenom,
        nom: nom,
        email: email,
        telephone: telephone,
        classe: classe,
        annee: annee,
        motDePasse: motDePasse,
      );
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  Future<void> deconnexion() async {
    erreur = null;
    isLoading = true;

    try {
      await repository.deconnexion();
      utilisateurConnecte = null;
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Réinitialisation mot de passe ─────────────────────────────────────────

  Future<void> reinitialiserMotDePasse(String email) async {
    erreur = null;
    isLoading = true;

    try {
      await repository.reinitialiserMotDePasse(email);
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Charger tous les utilisateurs (admin) ────────────────────────────────

  Future<void> chargementTousUtilisateurs() async {
    erreur = null;
    isLoading = true;

    try {
      tousUtilisateurs = await repository.recupererTousUtilisateurs();
    } catch (e) {
      erreur = e.toString();
    } finally {
      isLoading = false;
    }
  }

  // ── Getters pratiques ────────────────────────────────────────────────────

  bool get estConnecte => utilisateurConnecte != null;
  bool get estAdmin => utilisateurConnecte?.estAdmin ?? false;
}
