// Création de notre page d'inscription
// (même pattern que page_acceuil.dart de référence : StatefulWidget + setState)

import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class PageInscription extends StatefulWidget {
  const PageInscription({super.key});

  @override
  State<PageInscription> createState() => _PageInscriptionState();
}

class _PageInscriptionState extends State<PageInscription> {
  // Déclaration du ViewModel
  late UserViewModel _uvm;

  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _classeCtrl = TextEditingController();
  final _anneeCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();
  final _confirmerMotDePasseCtrl = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void initState() {
    super.initState();
    _uvm = UserViewModel(FirestoreUserRepository());
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telephoneCtrl.dispose();
    _classeCtrl.dispose();
    _anneeCtrl.dispose();
    _motDePasseCtrl.dispose();
    _confirmerMotDePasseCtrl.dispose();
    super.dispose();
  }

  Future<void> _inscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {});
    await _uvm.inscription(
      prenom: _prenomCtrl.text,
      nom: _nomCtrl.text,
      email: _emailCtrl.text,
      telephone: _telephoneCtrl.text,
      classe: _classeCtrl.text,
      annee: _anneeCtrl.text,
      motDePasse: _motDePasseCtrl.text,
    );
    setState(() {});

    if (_uvm.erreur == null && _uvm.utilisateurConnecte != null) {
      AppState().update(() {
        AppState().estConnecte = true;
        AppState().utilisateurConnecteUid = _uvm.utilisateurConnecte!.uid;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/page-accueil');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos informations',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Prénom & Nom ────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prenomCtrl,
                            textInputAction: TextInputAction.next,
                            decoration:
                                const InputDecoration(labelText: 'Prénom'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Le prénom est requis"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _nomCtrl,
                            textInputAction: TextInputAction.next,
                            decoration:
                                const InputDecoration(labelText: 'Nom'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Le nom est requis"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Email ───────────────────────────────────────────────
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Adresse email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "L'email est requis";
                        if (!v.contains('@')) return "Email invalide";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Téléphone ───────────────────────────────────────────
                    TextFormField(
                      controller: _telephoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Le téléphone est requis"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Classe & Année ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _classeCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                labelText: 'Classe (ex: L3)'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "La classe est requise"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _anneeCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                labelText: 'Année (ex: 2024-2025)'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "L'année est requise"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Mot de passe ────────────────────────────────────────
                    TextFormField(
                      controller: _motDePasseCtrl,
                      obscureText: !_motDePasseVisible,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_motDePasseVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(
                              () => _motDePasseVisible = !_motDePasseVisible),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Le mot de passe est requis";
                        if (v.length < 6) return "Minimum 6 caractères";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Confirmer mot de passe ──────────────────────────────
                    TextFormField(
                      controller: _confirmerMotDePasseCtrl,
                      obscureText: !_motDePasseVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _inscription(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) {
                        if (v != _motDePasseCtrl.text) {
                          return "Les mots de passe ne correspondent pas";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Erreur ───────────────────────────────────────────────────
              _buildErreur(context),

              // ── Bouton inscription ────────────────────────────────────────
              ElevatedButton(
                onPressed: _uvm.isLoading ? null : _inscription,
                child: _uvm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Créer mon compte"),
              ),
              const SizedBox(height: 16),

              // ── Retour connexion ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? "),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            child: Text(_uvm.erreur!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
