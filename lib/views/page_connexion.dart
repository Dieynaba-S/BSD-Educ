
// Création de notre page de connexion
import 'package:app_gestionsupportdecours/app_state.dart';
import 'package:app_gestionsupportdecours/repository/users/firestore_user_repository.dart';
import 'package:app_gestionsupportdecours/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  late UserViewModel _uvm;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void initState() {
    super.initState();
    _uvm = UserViewModel(FirestoreUserRepository());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  Future<void> _connexion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {});
    await _uvm.connexion(_emailCtrl.text, _motDePasseCtrl.text);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // ── Logo ────────────────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 16),

              // ── Sous-titre ───────────────────────────────────────────────
              Text(
                'Connectez-vous pour accéder à vos documents académiques',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              // ── Formulaire ───────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),

                    // Mot de passe
                    TextFormField(
                      controller: _motDePasseCtrl,
                      obscureText: !_motDePasseVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _connexion(),
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
                      validator: (valeur) {
                        if (valeur == null || valeur.isEmpty) {
                          return "Le mot de passe est requis";
                        }
                        if (valeur.length < 6) {
                          return "Minimum 6 caractères";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Mot de passe oublié ──────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/page-mot-de-passe-oublie'),
                  child: const Text('Mot de passe oublié ?'),
                ),
              ),
              const SizedBox(height: 8),

              // ── Affichage de l'erreur ────────────────────────────────────
              _buildErreur(context),

              // ── Bouton connexion ─────────────────────────────────────────
              ElevatedButton(
                onPressed: _uvm.isLoading ? null : _connexion,
                child: _uvm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 24),

              // ── Lien inscription ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas encore de compte ? "),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/page-inscription'),
                    child: const Text('Créer un compte'),
                  ),
                ],
              ),

              // ── Boutons thème ────────────────────────────────────────────
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      AppState().themeChoisi = ThemeMode.light;
                      AppState().update(() {});
                    },
                    icon: const Icon(Icons.light_mode),
                    tooltip: 'Mode clair',
                  ),
                  IconButton(
                    onPressed: () {
                      AppState().themeChoisi = ThemeMode.dark;
                      AppState().update(() {});
                    },
                    icon: const Icon(Icons.dark_mode),
                    tooltip: 'Mode sombre',
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