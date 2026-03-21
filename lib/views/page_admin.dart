
// Création de notre page administration
import 'dart:typed_data';
import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:app_gestionsupportdecours/repository/documents/firestore_document_repository.dart';
import 'package:app_gestionsupportdecours/repository/documents/storage_document_repository.dart';
import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/document_view_model.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PageAdmin extends StatefulWidget {
  const PageAdmin({super.key});

  @override
  State<PageAdmin> createState() => _PageAdminState();
}

class _PageAdminState extends State<PageAdmin>
    with SingleTickerProviderStateMixin {
  late DocumentViewModel _dvm;
  late UserViewModel _uvm;
  late TabController _tabController;
  final StorageDocumentRepository _storageRepo = StorageDocumentRepository();
  bool _uploadEnCours = false;

  @override
  void initState() {
    super.initState();
    _dvm = DocumentViewModel(FirestoreDocumentRepository());
    _uvm = UserViewModel(FirestoreUserRepository());
    _tabController = TabController(length: 2, vsync: this);
    _recupererDonnees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recupererDonnees() async {
    setState(() {});
    await _dvm.chargementDocuments();
    await _uvm.chargementTousUtilisateurs();
    setState(() {});
  }

  Future<void> _supprimerDocument(String id) async {
    setState(() {});
    await _dvm.supprimerDocument(id);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Document supprimé'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Documents', icon: Icon(Icons.folder)),
            Tab(text: 'Utilisateurs', icon: Icon(Icons.people)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherDialogueAjoutDocument(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un document'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGestionDocuments(context),
          _buildGestionUtilisateurs(context),
        ],
      ),
    );
  }

  Widget _buildGestionDocuments(BuildContext context) {
    if (_dvm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dvm.erreur != null) {
      return Center(
        child: Text("Erreur : ${_dvm.erreur!}",
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
    }
    if (_dvm.documents.isEmpty) {
      return const Center(child: Text("Aucun document"));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _dvm.documents.length,
      separatorBuilder: (context, index) => const Divider(height: 4),
      itemBuilder: (context, index) {
        final document = _dvm.documents[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: document.estExamen
                ? Colors.red.shade100
                : Colors.blue.shade100,
            child: Icon(
              document.estExamen ? Icons.quiz : Icons.menu_book,
              color: document.estExamen ? Colors.red : Colors.blue,
            ),
          ),
          title: Text(document.titre),
          subtitle: Text('${document.matiere} · ${document.classe}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmerSuppression(context, document),
          ),
        );
      },
    );
  }

  Widget _buildGestionUtilisateurs(BuildContext context) {
    if (_uvm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_uvm.erreur != null) {
      return Center(
        child: Text("Erreur : ${_uvm.erreur!}",
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
    }
    if (_uvm.tousUtilisateurs.isEmpty) {
      return const Center(child: Text("Aucun utilisateur"));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _uvm.tousUtilisateurs.length,
      separatorBuilder: (context, index) => const Divider(height: 4),
      itemBuilder: (context, index) {
        final user = _uvm.tousUtilisateurs[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${user.prenom[0]}${user.nom[0]}'),
          ),
          title: Text(user.prenomNom),
          subtitle: Text('${user.email} · ${user.classe}'),
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.estAdmin
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user.estAdmin ? 'Admin' : 'Étudiant',
              style: TextStyle(
                  color: user.estAdmin ? Colors.orange : Colors.green,
                  fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  void _confirmerSuppression(BuildContext context, DocumentModel document) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document ?'),
        content:
            Text('Voulez-vous vraiment supprimer "${document.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _supprimerDocument(document.id);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _afficherDialogueAjoutDocument(BuildContext context) {
    final titreCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final matiereCtrl = TextEditingController();
    final classeCtrl = TextEditingController();
    final anneeCtrl = TextEditingController();
    String typeSelectionne = 'examen';
    String? fichierNom;
    Uint8List? fichierBytes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Ajouter un document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Titre *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: matiereCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Matière *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: classeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Classe *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: anneeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Année *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: typeSelectionne,
                  decoration:
                      const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'examen', child: Text('Examen')),
                    DropdownMenuItem(
                        value: 'cours', child: Text('Cours')),
                    DropdownMenuItem(
                        value: 'autre', child: Text('Autre')),
                  ],
                  onChanged: (val) => setStateDialog(
                      () => typeSelectionne = val ?? 'examen'),
                ),
                const SizedBox(height: 16),

                // Bouton sélection fichier PDF
                OutlinedButton.icon(
                  onPressed: () async {
                    final result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                      withData: true,
                    );
                    if (result != null) {
                      setStateDialog(() {
                        fichierNom = result.files.first.name;
                        fichierBytes = result.files.first.bytes;
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    fichierNom ?? 'Sélectionner un PDF',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Nom du fichier sélectionné
                if (fichierNom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fichierNom!,
                            style: const TextStyle(
                                color: Colors.green, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barre de progression
                if (_uploadEnCours)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Upload en cours...',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _uploadEnCours
                  ? null
                  : () async {
                      if (titreCtrl.text.isEmpty ||
                          matiereCtrl.text.isEmpty ||
                          classeCtrl.text.isEmpty ||
                          anneeCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Remplissez tous les champs *')),
                        );
                        return;
                      }
                      if (fichierBytes == null || fichierNom == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Sélectionnez un fichier PDF')),
                        );
                        return;
                      }

                      setStateDialog(() => _uploadEnCours = true);
                      setState(() => _uploadEnCours = true);

                      try {
                        // 1. Upload Firebase Storage
                        final url =
                            await _storageRepo.uploaderFichier(
                          fichierBytes: fichierBytes!,
                          fichierNom: fichierNom!,
                        );

                        // 2. Enregistrer dans Firestore
                        await _storageRepo.enregistrerDocument(
                          titre: titreCtrl.text,
                          description: descriptionCtrl.text,
                          matiere: matiereCtrl.text,
                          classe: classeCtrl.text,
                          annee: anneeCtrl.text,
                          type: typeSelectionne,
                          fichierUrl: url,
                          fichierNom: fichierNom!,
                          uploadePar:
                              _uvm.utilisateurConnecte?.uid ?? '',
                        );

                        setState(() => _uploadEnCours = false);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Document ajouté avec succès ! ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _recupererDonnees();
                      } catch (e) {
                        setState(() => _uploadEnCours = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur : $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: _uploadEnCours
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Uploader'),
            ),
          ],
        ),
      ),
    );
  }
}