// Notre MODEL Utilisateur
// (même pattern que UserModel de référence : attributs privés + règles métier)

class UserModel {
  final String _uid;
  String _prenom;
  String _nom;
  String _email;
  String _telephone;
  String _classe;
  String _annee;
  final String _role; // 'etudiant' | 'admin'

  // Création de notre constructeur
  UserModel({
    required String uid,
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String classe,
    required String annee,
    String role = 'etudiant',
  })  : _uid = uid,
        _prenom = prenom,
        _nom = nom,
        _email = email,
        _telephone = telephone,
        _classe = classe,
        _annee = annee,
        _role = role {
    // Règles métier appliquées à la construction
    _validationUid(_uid);
    _validationPrenom(_prenom);
    _validationNom(_nom);
    _validationEmail(_email);
    _validationTelephone(_telephone);
    _validationClasse(_classe);
  }

  // ── Règles métier privées ────────────────────────────────────────────────

  void _validationUid(String uid) {
    if (uid.trim().isEmpty) {
      throw Exception("L'identifiant utilisateur ne peut pas être vide");
    }
  }

  void _validationPrenom(String prenom) {
    if (prenom.trim().isEmpty) {
      throw Exception("Le prénom ne doit pas être vide");
    }
  }

  void _validationNom(String nom) {
    if (nom.trim().isEmpty) {
      throw Exception("Le nom ne doit pas être vide");
    }
  }

  void _validationEmail(String email) {
    if (!email.trim().contains('@')) {
      throw Exception("L'adresse email doit contenir '@'");
    }
  }

  void _validationTelephone(String telephone) {
    if (telephone.trim().isEmpty) {
      throw Exception("Le numéro de téléphone ne doit pas être vide");
    }
  }

  void _validationClasse(String classe) {
    if (classe.trim().isEmpty) {
      throw Exception("La classe ne doit pas être vide");
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  String get uid => _uid;
  String get prenom => _prenom;
  String get nom => _nom;
  String get prenomNom => '$_prenom $_nom';
  String get email => _email;
  String get telephone => _telephone;
  String get classe => _classe;
  String get annee => _annee;
  String get role => _role;
  bool get estAdmin => _role == 'admin';

  // ── Méthodes métier ──────────────────────────────────────────────────────

  void changerPrenom(String nouveauPrenom) {
    _validationPrenom(nouveauPrenom);
    _prenom = nouveauPrenom;
  }

  void changerNom(String nouveauNom) {
    _validationNom(nouveauNom);
    _nom = nouveauNom;
  }

  void changerEmail(String nouvelEmail) {
    _validationEmail(nouvelEmail);
    _email = nouvelEmail;
  }

  void changerTelephone(String nouveauTelephone) {
    _validationTelephone(nouveauTelephone);
    _telephone = nouveauTelephone;
  }

  void changerClasse(String nouvelleClasse) {
    _validationClasse(nouvelleClasse);
    _classe = nouvelleClasse;
  }
}
