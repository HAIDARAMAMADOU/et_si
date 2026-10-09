import '../../../app/translations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_repository.dart';
import '../../../app/theme.dart';

void showAuthError(BuildContext context, Object error) {
  final message = switch (error) {
    FirebaseAuthException(code: 'invalid-email') => tr(
      context,
      'Adresse e-mail invalide.',
    ),
    FirebaseAuthException(code: 'user-not-found') => tr(
      context,
      'Aucun compte ne correspond à cette adresse.',
    ),
    FirebaseAuthException(code: 'wrong-password') => tr(
      context,
      'Mot de passe incorrect.',
    ),
    FirebaseAuthException(code: 'invalid-credential') => tr(
      context,
      'Adresse e-mail ou mot de passe incorrect.',
    ),
    FirebaseAuthException(code: 'email-already-in-use') => tr(
      context,
      'Cette adresse e-mail est déjà utilisée.',
    ),
    FirebaseAuthException(code: 'weak-password') => tr(
      context,
      'Choisis un mot de passe plus robuste.',
    ),
    FirebaseAuthException(code: 'network-request-failed') => tr(
      context,
      'Connexion impossible. Vérifie ton réseau.',
    ),
    _ => tr(context, 'Une erreur est survenue. Réessaie.'),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: EtSiTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                tr(context, 'ET SI ?'),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: EtSiTheme.text,
                ),
              ),
              SizedBox(height: 16),
              Text(
                tr(context, 'Et si tu essayais ?'),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: EtSiTheme.text,
                ),
              ),
              SizedBox(height: 12),
              Text(
                tr(
                  context,
                  'Transforme tes idées en petites expériences. Essaie, observe et découvre ce que tu peux apprendre.',
                ),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: EtSiTheme.muted,
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  child: Text(tr(context, 'Créer mon compte')),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: Text(tr(context, 'J’ai déjà un compte')),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: _email.text, password: _password.text);
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Content de te revoir.'),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: EtSiTheme.text,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  tr(context, 'Connecte-toi pour reprendre tes expériences.'),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: tr(context, 'Adresse e-mail'),
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty || !email.contains('@')) {
                      return tr(context, 'Saisis une adresse e-mail valide.');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: tr(context, 'Mot de passe'),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscure
                          ? tr(context, 'Afficher le mot de passe')
                          : tr(context, 'Masquer le mot de passe'),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr(context, 'Saisis ton mot de passe.');
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/reset'),
                    child: Text(tr(context, 'Mot de passe oublié ?')),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(tr(context, 'Se connecter')),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(tr(context, 'Créer un compte')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(email: _email.text, password: _password.text);
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Tout commence par un essai.'),
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: EtSiTheme.text,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  tr(
                    context,
                    'Crée ton compte et donne une chance à tes idées.',
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.newUsername],
                  decoration: InputDecoration(
                    labelText: tr(context, 'Adresse e-mail'),
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty || !email.contains('@')) {
                      return tr(context, 'Saisis une adresse e-mail valide.');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: tr(context, 'Mot de passe'),
                    helperText: tr(context, 'Au moins 6 caractères'),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscure
                          ? tr(context, 'Afficher le mot de passe')
                          : tr(context, 'Masquer le mot de passe'),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return tr(
                        context,
                        'Le mot de passe doit contenir 6 caractères minimum.',
                      );
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Confirmer le mot de passe'),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != _password.text) {
                      return tr(
                        context,
                        'Les mots de passe ne correspondent pas.',
                      );
                    }
                    return null;
                  },
                ),
                SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(tr(context, 'Créer mon compte')),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(tr(context, 'J’ai déjà un compte')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: _sent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 52,
                    color: EtSiTheme.primary,
                  ),
                  SizedBox(height: 24),
                  Text(
                    tr(context, 'Vérifie ta boîte mail.'),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Si un compte correspond à cette adresse, '
                    'tu recevras les instructions de réinitialisation.',
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: Text(tr(context, 'Retour à la connexion')),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'Un mot de passe à retrouver.'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Saisis ton adresse e-mail pour recevoir '
                      'les instructions de réinitialisation.',
                    ),
                    SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: tr(context, 'Adresse e-mail'),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return tr(
                            context,
                            'Saisis une adresse e-mail valide.',
                          );
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(tr(context, 'Envoyer les instructions')),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'ET SI ?')),
        actions: [
          IconButton(
            tooltip: tr(context, 'Se déconnecter'),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 56,
                color: EtSiTheme.primary,
              ),
              SizedBox(height: 20),
              Text(
                tr(context, 'Bienvenue dans ET SI ?'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 12),
              Text(user?.email ?? '', textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text(
                'Ton espace est prêt. Nous allons maintenant '
                'construire tes premières expériences.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
