
import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PageDetailDocument extends StatefulWidget {
  final DocumentModel document;

  const PageDetailDocument({super.key, required this.document});

  @override
  State<PageDetailDocument> createState() => _PageDetailDocumentState();
}

class _PageDetailDocumentState extends State<PageDetailDocument> {

  Future<void> _ouvrirLien(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien du fichier introuvable'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          doc.titre,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Icône et badge ──────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: doc.estExamen
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    child: Icon(
                      doc.estExamen ? Icons.quiz : Icons.menu_book,
                      size: 55,
                      color: doc.estExamen ? Colors.red : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: doc.estExamen
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: doc.estExamen ? Colors.red : Colors.blue,
                      ),
                    ),
                    child: Text(
                      doc.estExamen ? 'Sujet d\'examen' : 'Support de cours',
                      style: TextStyle(
                        color: doc.estExamen ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Informations ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoLigne('Titre', doc.titre, Icons.title),
                    const Divider(),
                    _buildInfoLigne('Matière', doc.matiere, Icons.subject),
                    const Divider(),
                    _buildInfoLigne('Classe', doc.classe, Icons.class_),
                    const Divider(),
                    _buildInfoLigne('Année', doc.annee, Icons.calendar_today),
                    if (doc.description.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoLigne('Description', doc.description, Icons.description),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Boutons ─────────────────────────────────────────────────
            // Bouton Visualiser
            ElevatedButton.icon(
              onPressed: doc.fichierUrl.isNotEmpty
                  ? () => _ouvrirLien(doc.fichierUrl)
                  : null,
              icon: const Icon(Icons.visibility),
              label: const Text('Visualiser le document'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton Télécharger
            OutlinedButton.icon(
              onPressed: doc.fichierUrl.isNotEmpty
                  ? () => _ouvrirLien(
                      doc.fichierUrl.replaceAll('/view', '/export?format=pdf'))
                  : null,
              icon: const Icon(Icons.download),
              label: const Text('Télécharger le document'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Info Google Drive
            if (doc.fichierUrl.contains('drive.google.com'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ce document est hébergé sur Google Drive. Une connexion internet est requise.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLigne(String label, String valeur, IconData icone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone,
              size: 20,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}