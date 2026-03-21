// Notre DTO Document (même pattern que UserDto de référence)

class DocumentDto {
  final String id;
  final String titre;
  final String description;
  final String matiere;
  final String classe;
  final String annee;
  final String type;        // 'examen' | 'cours' | 'autre'
  final String fichierUrl;
  final String fichierNom;
  final String uploadePar;  // uid de l'admin
  final String dateCreation;

  // Définir notre constructeur
  DocumentDto({
    required this.id,
    required this.titre,
    required this.description,
    required this.matiere,
    required this.classe,
    required this.annee,
    required this.type,
    required this.fichierUrl,
    required this.fichierNom,
    required this.uploadePar,
    required this.dateCreation,
  });

  // Depuis Firestore
  factory DocumentDto.fromJson(Map<String, dynamic> json, String id) {
    return DocumentDto(
      id: id,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      matiere: json['matiere'] as String? ?? '',
      classe: json['classe'] as String? ?? '',
      annee: json['annee'] as String? ?? '',
      type: json['type'] as String? ?? 'autre',
      fichierUrl: json['fichierUrl'] as String? ?? '',
      fichierNom: json['fichierNom'] as String? ?? '',
      uploadePar: json['uploadePar'] as String? ?? '',
      dateCreation: json['dateCreation'] as String? ?? '',
    );
  }

  // Vers Firestore
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'matiere': matiere,
      'classe': classe,
      'annee': annee,
      'type': type,
      'fichierUrl': fichierUrl,
      'fichierNom': fichierNom,
      'uploadePar': uploadePar,
      'dateCreation': dateCreation,
    };
  }
}
