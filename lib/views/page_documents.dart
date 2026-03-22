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

  final _rechercheCtrl = TextEditingController();
  String _filtreClasse = 'Toutes';
  final List<String> _classes = ['Toutes', 'L1', 'L2', 'L3', 'M1', 'M2'];

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
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _recupererDocuments() async {
    setState(() {});
    await _dvm.chargementDocuments();
    setState(() {});
  }

  Future<void> _rechercherDocuments(String motCle) async {
    setState(() {});
    await _dvm.rechercherDocuments(motCle);
    setState(() {});
  }

  // Filtrer par classe
  List<DocumentModel> _filtrerParType(String type) {
    return _dvm.documentsFiltres.where((doc) {
      final matchType = doc.type == type;
      final matchClasse = _filtreClasse == 'Toutes' ||
          doc.classe.toLowerCase() == _filtreClasse.toLowerCase();
      return matchType && matchClasse;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.quiz),
              text: 'Examens',
            ),
            Tab(
              icon: Icon(Icons.menu_book),
              text: 'Cours',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Barre de recherche ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _rechercheCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
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

          // ── Filtre par classe ──────────────────────────────────────────
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classe = _classes[index];
                final selectionne = _filtreClasse == classe;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(classe),
                    selected: selectionne,
                    onSelected: (val) {
                      setState(() => _filtreClasse = classe);
                    },
                    selectedColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Liste des documents ────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListeDocuments(context, 'examen'),
                _buildListeDocuments(context, 'cours'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode qui retourne le Widget selon l'état
  Widget _buildListeDocuments(BuildContext context, String type) {
    // Chargement en cours
    if (_dvm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // S'il y a une erreur
    if (_dvm.erreur != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              "Erreur : ${_dvm.erreur!}",
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _recupererDocuments,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final filtres = _filtrerParType(type);

    // Si la liste est vide
    if (filtres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'examen' ? Icons.quiz : Icons.menu_book,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _rechercheCtrl.text.isNotEmpty
                  ? 'Aucun résultat pour\n"${_rechercheCtrl.text}"'
                  : _filtreClasse != 'Toutes'
                      ? 'Aucun ${type == 'examen' ? 'examen' : 'cours'}\npour la classe $_filtreClasse'
                      : 'Aucun ${type == 'examen' ? 'examen' : 'cours'}\ndisponible',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Liste des documents filtrés
    return RefreshIndicator(
      onRefresh: _recupererDocuments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtres.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final document = filtres[index];
          return _buildDocumentCard(context, document);
        },
      ),
    );
  }

  // Widget carte document
  Widget _buildDocumentCard(
      BuildContext context, DocumentModel document) {
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
                Icon(Icons.subject,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                const SizedBox(width: 4),
                Text(document.matiere,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.class_,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                const SizedBox(width: 4),
                Text(document.classe,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                const SizedBox(width: 4),
                Text(document.annee,
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
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
