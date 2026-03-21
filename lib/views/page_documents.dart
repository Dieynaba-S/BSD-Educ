// Création de notre page documents (filtrage par classe/matière)
// (même pattern que page_acceuil.dart de référence)

import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:app_gestionsupportdecours/repository/documents/firestore_document_repository.dart';
import 'package:app_gestionsupportdecours/view_models/document_view_model.dart';
import 'package:flutter/material.dart';

class PageDocuments extends StatefulWidget {
  const PageDocuments({super.key});

  @override
  State<PageDocuments> createState() => _PageDocumentsState();
}

class _PageDocumentsState extends State<PageDocuments>
    with SingleTickerProviderStateMixin {
  // Déclaration du ViewModel
  late DocumentViewModel _dvm;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _dvm = DocumentViewModel(FirestoreDocumentRepository());
    _tabController = TabController(length: 2, vsync: this);

    _recupererDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recupererDocuments() async {
    setState(() {});
    await _dvm.chargementDocuments();
    setState(() {});
  }

  Future<void> _filtrerParClasse(String classe) async {
    setState(() {});
    await _dvm.chargementDocumentsParClasse(classe);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Examens', icon: Icon(Icons.quiz)),
            Tab(text: 'Cours', icon: Icon(Icons.menu_book)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListeDocuments(context, 'examen'),
          _buildListeDocuments(context, 'cours'),
        ],
      ),
    );
  }

  // Méthode qui retourne le Widget (même pattern que _buildBody de référence)
  Widget _buildListeDocuments(BuildContext context, String type) {
    if (_dvm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dvm.erreur != null) {
      return Center(
        child: Text(
          "Erreur : ${_dvm.erreur!}",
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    final filtres = _dvm.documentsFiltres
        .where((doc) => doc.type == type)
        .toList();

    if (filtres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'examen' ? Icons.quiz : Icons.menu_book,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text("Aucun ${type == 'examen' ? 'examen' : 'cours'} disponible",
                style:
                    const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtres.length,
      separatorBuilder: (context, index) => const Divider(height: 4),
      itemBuilder: (context, index) {
        final document = filtres[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: type == 'examen'
                ? Colors.red.shade100
                : Colors.blue.shade100,
            child: Icon(
              type == 'examen' ? Icons.quiz : Icons.menu_book,
              color: type == 'examen' ? Colors.red : Colors.blue,
            ),
          ),
          title: Text(document.titre,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
              '${document.matiere} · ${document.classe} · ${document.annee}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/page-detail-document',
              arguments: document,
            );
          },
        );
      },
    );
  }
}
