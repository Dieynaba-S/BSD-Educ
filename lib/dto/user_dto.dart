// Notre DTO Utilisateur (même pattern que UserDto de référence)

class UserDto {
  final String uid;
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String classe;
  final String annee;
  final String role;

  // Définir notre constructeur
  UserDto({
    required this.uid,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.classe,
    required this.annee,
    required this.role,
  });

  // Depuis Firestore / JSON
  factory UserDto.fromJson(Map<String, dynamic> json, String uid) {
    return UserDto(
      uid: uid,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      classe: json['classe'] as String? ?? '',
      annee: json['annee'] as String? ?? '',
      role: json['role'] as String? ?? 'etudiant',
    );
  }

  // Vers Firestore / JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'classe': classe,
      'annee': annee,
      'role': role,
    };
  }
}
