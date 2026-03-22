// Création de notre page de récupération de mot de passe
// (même pattern que les autres pages de référence)

import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class PageMotDePasseOublie extends StatefulWidget {
  const PageMotDePasseOublie({super.key});

  @override
  State<PageMotDePasseOublie> createState() => _PageMotDePasseOublieState();
}

class _PageMotDePasseOublieState extends State<PageMotDePasseOublie> {
  // Déclaration du ViewModel
  late UserViewModel _uvm;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailEnvoye = false;

  @override
  void initState() {
    super.initState();
    _uvm = UserViewModel(FirestoreUserRepository());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _reinitialiser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {});
    await _uvm.reinitialiserMotDePasse(_emailCtrl.text);
    setState(() {});

    if (_uvm.erreur == null) {
      setState(() => _emailEnvoye = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: _emailEnvoye ? _buildSucces() : _buildFormulaire(),
        ),
      ),
    );
  }

  // ── Formulaire ─────────────────────────────────────────────────────────────
  Widget _buildFormulaire() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Icône
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Titre
        Text(
          'Mot de passe oublié ?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Formulaire email
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _reinitialiser(),
            decoration: const InputDecoration(
              labelText: 'Adresse email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (valeur) {
              if (valeur == null || valeur.trim().isEmpty) {
                return "L'email est requis";
              }
              if (!valeur.contains('@')) {
                return "Email invalide";
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),

        // Affichage erreur
        _buildErreur(context),

        // Bouton envoyer
        ElevatedButton(
          onPressed: _uvm.isLoading ? null : _reinitialiser,
          child: _uvm.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Envoyer le lien'),
        ),
        const SizedBox(height: 16),

        // Retour connexion
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour à la connexion'),
          ),
        ),
      ],
    );
  }

  // ── État succès ─────────────────────────────────────────────────────────────
  Widget _buildSucces() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône succès
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Email envoyé ! ✅',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Text(
          'Un lien de réinitialisation a été envoyé à\n${_emailCtrl.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vérifiez aussi vos spams si vous ne trouvez pas l\'email.',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour à la connexion'),
        ),
      ],
    );
  }

  // ── Widget erreur ───────────────────────────────────────────────────────────
  Widget _buildErreur(BuildContext context) {
    if (_uvm.erreur == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _uvm.erreur!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}