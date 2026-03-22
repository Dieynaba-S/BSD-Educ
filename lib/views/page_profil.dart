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

  Future<void> _seDeconnecter() async {
    await _uvm.deconnexion();
    AppState().update(() {
      AppState().estConnecte = false;
      AppState().utilisateurConnecteUid = null;
    });
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/page-connexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            onPressed: _seDeconnecter,
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Center(child: _buildBody(context)),
    );
  }

  // Méthode qui retourne le Widget selon l'état
  Widget _buildBody(BuildContext context) {
    // Chargement en cours
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
            radius: 55,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${user.prenom[0]}${user.nom[0]}'.toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Nom complet ───────────────────────────────────────────────
          Text(
            user.prenomNom,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // ── Badge rôle ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: user.estAdmin
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.estAdmin ? Colors.orange : Colors.green,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.estAdmin
                      ? Icons.admin_panel_settings
                      : Icons.school,
                  size: 16,
                  color: user.estAdmin ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  user.estAdmin ? 'Administrateur' : 'Étudiant',
                  style: TextStyle(
                    color: user.estAdmin ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Informations ──────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                      Icons.email_outlined, 'Email', user.email),
                  const Divider(),
                  _buildInfoTile(
                      Icons.phone_outlined, 'Téléphone', user.telephone),
                  const Divider(),
                  _buildInfoTile(
                      Icons.class_, 'Classe', user.classe),
                  const Divider(),
                  _buildInfoTile(
                      Icons.calendar_today, 'Année', user.annee),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Bouton déconnexion ────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _seDeconnecter,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icone, String label, String valeur) {
    return ListTile(
      leading: Icon(icone,
          color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        valeur,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}