// Création de notre page d'accueil - Liste des documents
// (même pattern que page_acceuil.dart de référence : initState + _recupereData + _buildBody)

import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:app_gestionsupportdecours/repository/documents/firestore_document_repository.dart';
import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/document_view_model.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key});

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  // Déclaration des ViewModels
  late DocumentViewModel _dvm;
  late UserViewModel _uvm;

  final _rechercheCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _dvm = DocumentViewModel(FirestoreDocumentRepository());
    _uvm = UserViewModel(FirestoreUserRepository());

    _recupererDocuments();
    _recupererUtilisateurConnecte();
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _recupererDocuments() async {
    setState(() {});
    await _dvm.chargementDocuments();
    setState(() {});
  }

  Future<void> _recupererUtilisateurConnecte() async {
    final uid = AppState().utilisateurConnecteUid;
    if (uid != null) {
      final user = await _uvm.repository.recupererUtilisateur(uid);
      setState(() {
        _uvm.utilisateurConnecte = user;
      });
    }
  }

  Future<void> _rechercherDocuments(String motCle) async {
    setState(() {});
    await _dvm.rechercherDocuments(motCle);
    setState(() {});
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
        title: const Text('BSD Educ 📚'),
        actions: [
          IconButton(
            onPressed: () {
              AppState().themeChoisi = ThemeMode.light;
              AppState().update(() {});
            },
            icon: const Icon(Icons.light_mode),
          ),
          IconButton(
            onPressed: () {
              AppState().themeChoisi = ThemeMode.dark;
              AppState().update(() {});
            },
            icon: const Icon(Icons.dark_mode),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/page-profil'),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: _seDeconnecter,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // Bouton Admin visible uniquement pour les admins
      floatingActionButton: _uvm.utilisateurConnecte?.estAdmin == true
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/page-admin'),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin'),
            )
          : null,
      body: Column(
        children: [
          // ── Bienvenue ──────────────────────────────────────────────────
          if (_uvm.utilisateurConnecte != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                'Bienvenue ${_uvm.utilisateurConnecte!.prenomNom} 👋',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

          // ── Barre de recherche ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _rechercheCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un document...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _rechercheCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _rechercheCtrl.clear();
                          _dvm.reinitialiserFiltres();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (valeur) => _rechercherDocuments(valeur),
            ),
          ),

          // ── Compteur de documents ──────────────────────────────────────
          if (_dvm.documentsFiltres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_dvm.documentsFiltres.length} document(s) trouvé(s)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // ── Corps de la page ────────────────────────────────────────────
          Expanded(child: Center(child: _buildBody(context))),
        ],
      ),
    );
  }

  // Méthode qui retourne le Widget selon l'état
  Widget _buildBody(BuildContext context) {
    // Chargement en cours
    if (_dvm.isLoading) {
      return const CircularProgressIndicator();
    }

    // S'il y a une erreur
    if (_dvm.erreur != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            "Erreur : ${_dvm.erreur!}",
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _recupererDocuments,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      );
    }

    // Si la liste est vide
    if (_dvm.documentsFiltres.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _rechercheCtrl.text.isNotEmpty
                ? "Aucun document trouvé pour\n\"${_rechercheCtrl.text}\""
                : "Aucun document disponible",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      );
    }

    // Liste des documents
    return RefreshIndicator(
      onRefresh: _recupererDocuments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _dvm.documentsFiltres.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final document = _dvm.documentsFiltres[index];
          return _buildDocumentCard(context, document);
        },
      ),
    );
  }

  // Widget carte document
  Widget _buildDocumentCard(BuildContext context, DocumentModel document) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: document.estExamen
              ? Colors.red.shade100
              : Colors.blue.shade100,
          child: Icon(
            document.estExamen ? Icons.quiz : Icons.menu_book,
            color: document.estExamen ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          document.titre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.subject, size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(document.matiere,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.class_, size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(document.classe,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: document.estExamen
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                document.estExamen ? 'Examen' : 'Cours',
                style: TextStyle(
                  fontSize: 11,
                  color: document.estExamen ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _dvm.selectionnerDocument(document);
          Navigator.pushNamed(
            context,
            '/page-detail-document',
            arguments: document,
          );
        },
      ),
    );
  }
}
