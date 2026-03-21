// Notre MODEL Document
// (même pattern que UserModel de référence : attributs privés + règles métier)

class DocumentModel {
  final String _id;
  String _titre;
  String _description;
  String _matiere;
  String _classe;
  String _annee;
  final String _type;       // 'examen' | 'cours' | 'autre'
  final String _fichierUrl;
  final String _fichierNom;
  final String _uploadePar;
  final DateTime _dateCreation;

  // Création de notre constructeur
  DocumentModel({
    required String id,
    required String titre,
    required String description,
    required String matiere,
    required String classe,
    required String annee,
    required String type,
    required String fichierUrl,
    required String fichierNom,
    required String uploadePar,
    required DateTime dateCreation,
  })  : _id = id,
        _titre = titre,
        _description = description,
        _matiere = matiere,
        _classe = classe,
        _annee = annee,
        _type = type,
        _fichierUrl = fichierUrl,
        _fichierNom = fichierNom,
        _uploadePar = uploadePar,
        _dateCreation = dateCreation {
    // Règles métier appliquées à la construction
    _validationTitre(_titre);
    _validationMatiere(_matiere);
    _validationFichierUrl(_fichierUrl);
    _validationType(_type);
  }

  // ── Règles métier privées ────────────────────────────────────────────────

  void _validationTitre(String titre) {
    if (titre.trim().isEmpty) {
      throw Exception("Le titre du document ne doit pas être vide");
    }
    if (titre.trim().length < 3) {
      throw Exception("Le titre doit contenir au moins 3 caractères");
    }
  }

  void _validationMatiere(String matiere) {
    if (matiere.trim().isEmpty) {
      throw Exception("La matière ne doit pas être vide");
    }
  }

  void _validationFichierUrl(String fichierUrl) {
    if (fichierUrl.trim().isEmpty) {
      throw Exception("L'URL du fichier ne doit pas être vide");
    }
  }

  void _validationType(String type) {
    const typesValides = ['examen', 'cours', 'autre'];
    if (!typesValides.contains(type)) {
      throw Exception(
          "Le type doit être l'un des suivants : ${typesValides.join(', ')}");
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  String get id => _id;
  String get titre => _titre;
  String get description => _description;
  String get matiere => _matiere;
  String get classe => _classe;
  String get annee => _annee;
  String get type => _type;
  String get fichierUrl => _fichierUrl;
  String get fichierNom => _fichierNom;
  String get uploadePar => _uploadePar;
  DateTime get dateCreation => _dateCreation;
  bool get estExamen => _type == 'examen';
  bool get estCours => _type == 'cours';

  // ── Méthodes métier ──────────────────────────────────────────────────────

  void changerTitre(String nouveauTitre) {
    _validationTitre(nouveauTitre);
    _titre = nouveauTitre;
  }

  void changerDescription(String nouvelleDescription) {
    _description = nouvelleDescription;
  }

  void changerMatiere(String nouvelleMatiere) {
    _validationMatiere(nouvelleMatiere);
    _matiere = nouvelleMatiere;
  }
}
