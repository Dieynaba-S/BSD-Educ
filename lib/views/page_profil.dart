// Création de notre page profil
// (même pattern StatefulWidget de référence)

import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({super.key});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  // Déclaration du ViewModel
  late UserViewModel _uvm;

  @override
  void initState() {
    super.initState();
    _uvm = UserViewModel(FirestoreUserRepository());
    _recupererProfil();
  }

  Future<void> _recupererProfil() async {
    final uid = AppState().utilisateurConnecteUid;
    if (uid == null) return;

    setState(() {});
    final user = await _uvm.repository.recupererUtilisateur(uid);
    setState(() {
      _uvm.utilisateurConnecte = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Center(child: _buildBody(context)),
    );
  }

  // Méthode qui retourne le Widget (même pattern que _buildBody de référence)
  Widget _buildBody(BuildContext context) {
    if (_uvm.utilisateurConnecte == null) {
      return const CircularProgressIndicator();
    }

    final user = _uvm.utilisateurConnecte!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Avatar ────────────────────────────────────────────────────
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${user.prenom[0]}${user.nom[0]}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.prenomNom,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.estAdmin
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.estAdmin ? 'Administrateur' : 'Étudiant',
              style: TextStyle(
                color: user.estAdmin ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Informations ──────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoTile(Icons.email_outlined, 'Email', user.email),
                  const Divider(),
                  _buildInfoTile(Icons.phone_outlined, 'Téléphone', user.telephone),
                  const Divider(),
                  _buildInfoTile(Icons.class_, 'Classe', user.classe),
                  const Divider(),
                  _buildInfoTile(Icons.calendar_today, 'Année', user.annee),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icone, String label, String valeur) {
    return ListTile(
      leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(valeur,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
