// Création de notre page détail document
// (même pattern StatefulWidget de référence)

import 'package:app_gestionsupportdecours/models/document_model.dart';
import 'package:flutter/material.dart';

class PageDetailDocument extends StatefulWidget {
  final DocumentModel document;

  const PageDetailDocument({super.key, required this.document});

  @override
  State<PageDetailDocument> createState() => _PageDetailDocumentState();
}

class _PageDetailDocumentState extends State<PageDetailDocument> {
  bool _telechargementEnCours = false;

  Future<void> _telecharger() async {
    setState(() => _telechargementEnCours = true);

    // TODO: Implémenter le téléchargement via Dio + path_provider
    await Future.delayed(const Duration(seconds: 2)); // Simulation

    setState(() => _telechargementEnCours = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléchargement terminé !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.titre, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icône et badge ───────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: doc.estExamen
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    child: Icon(
                      doc.estExamen ? Icons.quiz : Icons.menu_book,
                      size: 48,
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
            const SizedBox(height: 24),

            // ── Infos ────────────────────────────────────────────────────
            _buildInfoLigne('Titre', doc.titre, Icons.title),
            _buildInfoLigne('Matière', doc.matiere, Icons.subject),
            _buildInfoLigne('Classe', doc.classe, Icons.class_),
            _buildInfoLigne('Année', doc.annee, Icons.calendar_today),
            if (doc.description.isNotEmpty)
              _buildInfoLigne('Description', doc.description, Icons.description),
            const SizedBox(height: 32),

            // ── Bouton téléchargement ─────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _telechargementEnCours ? null : _telecharger,
              icon: _telechargementEnCours
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download),
              label: Text(_telechargementEnCours
                  ? 'Téléchargement...'
                  : 'Télécharger le fichier'),
            ),
            const SizedBox(height: 12),

            // ── Bouton visualisation ──────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Naviguer vers le lecteur PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visualisation PDF bientôt disponible')),
                );
              },
              icon: const Icon(Icons.visibility),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: const Text('Visualiser le fichier'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ligne d'information
  Widget _buildInfoLigne(String label, String valeur, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12)),
                Text(valeur,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
