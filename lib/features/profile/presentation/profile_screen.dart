import '../../../app/translations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../app/locale_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../experiences/data/experience_repository.dart';
import '../../experiences/domain/experience.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _savingName = false;
  bool _nameInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _initials(User? user) {
    final name = user?.displayName?.trim() ?? '';
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      return parts.length > 1
          ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
          : parts.first.substring(0, 1).toUpperCase();
    }
    final email = user?.email ?? '';
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?';
  }

  Future<void> _editName(User? user) async {
    if (user == null || _savingName) return;

    _nameController.text = user.displayName ?? '';
    final formKey = GlobalKey<FormState>();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(context, 'Modifier mon prénom')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: tr(context, 'Nom affiché'),
              hintText: tr(context, 'Ex. : Aïcha Koné'),
            ),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return tr(context, 'Saisis un nom.');
              if (name.length > 60) {
                return tr(context, '60 caractères maximum.');
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr(context, 'Annuler')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, _nameController.text.trim());
              }
            },
            child: Text(tr(context, 'Enregistrer')),
          ),
        ],
      ),
    );

    if (value == null || !mounted) return;

    setState(() => _savingName = true);
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(value);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'Ton profil a été mis à jour.'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context, 'Impossible de modifier ton profil. Réessaie.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _resetPassword(User? user) async {
    final email = user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, 'Aucune adresse e-mail disponible.')),
        ),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context, 'Un e-mail de réinitialisation a été envoyé.'),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'Envoi impossible. Réessaie plus tard.')),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(context, 'Se déconnecter ?')),
        content: Text(tr(context, 'Tu pourras te reconnecter à tout moment.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr(context, 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr(context, 'Se déconnecter')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final experienceStream = ref
        .watch(experienceRepositoryProvider)
        .watchExperiences();

    if (!_nameInitialized) {
      _nameController.text = user?.displayName ?? '';
      _nameInitialized = true;
    }

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : tr(context, 'Mon profil');

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Mon profil')),
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFE9E7E2)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFFEAEFFD),
                    foregroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: Text(
                      _initials(user),
                      style: TextStyle(
                        color: EtSiTheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: EtSiTheme.text,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    user?.email ?? tr(context, 'Adresse e-mail indisponible'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: EtSiTheme.muted),
                  ),
                  SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _savingName ? null : () => _editName(user),
                    icon: _savingName
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.edit_outlined),
                    label: Text(tr(context, 'Modifier mon profil')),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Text(
              tr(context, 'Mon parcours'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: EtSiTheme.text,
              ),
            ),
            SizedBox(height: 12),
            StreamBuilder<List<Experience>>(
              stream: experienceStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _StatsErrorCard();
                }
                if (!snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final experiences = snapshot.data!;
                final active = experiences
                    .where((e) => e.status == ExperienceStatus.active)
                    .length;
                final completed = experiences
                    .where((e) => e.status == ExperienceStatus.completed)
                    .length;
                final abandoned = experiences
                    .where((e) => e.status == ExperienceStatus.abandoned)
                    .length;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.bolt_outlined,
                            label: tr(context, 'En cours'),
                            value: active,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.check_circle_outline,
                            label: tr(context, 'Terminées'),
                            value: completed,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.refresh_rounded,
                            label: tr(context, 'Abandonnées'),
                            value: abandoned,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.lightbulb_outline,
                            label: tr(context, 'Total'),
                            value: experiences.length,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 28),
            Text(
              tr(context, 'Langue'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: EtSiTheme.text,
              ),
            ),
            SizedBox(height: 12),
            _LanguageSelector(
              selectedLocale: ref.watch(localeProvider),
              onChanged: (locale) {
                ref.read(localeProvider.notifier).setLocale(locale);
              },
            ),
            SizedBox(height: 28),
            Text(
              tr(context, 'Compte et sécurité'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: EtSiTheme.text,
              ),
            ),
            SizedBox(height: 12),
            _ProfileAction(
              icon: Icons.lock_reset_outlined,
              title: tr(context, 'Réinitialiser mon mot de passe'),
              subtitle: tr(context, 'Recevoir un lien par e-mail'),
              onTap: () => _resetPassword(user),
            ),
            SizedBox(height: 10),
            _ProfileAction(
              icon: Icons.logout,
              title: tr(context, 'Se déconnecter'),
              subtitle: tr(context, 'Fermer ta session sur cet appareil'),
              destructive: true,
              onTap: _signOut,
            ),
            SizedBox(height: 28),
            Center(
              child: Text(
                tr(context, 'ET SI ? · Chaque essai compte.'),
                style: TextStyle(color: EtSiTheme.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE9E7E2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: EtSiTheme.primary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: EtSiTheme.text,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: EtSiTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red.shade700 : EtSiTheme.text;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Color(0xFFE9E7E2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatsErrorCard extends StatelessWidget {
  const _StatsErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE9E7E2)),
      ),
      child: Text(
        tr(context, 'Les statistiques sont momentanément indisponibles.'),
        style: TextStyle(color: EtSiTheme.muted),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedLocale,
    required this.onChanged,
  });

  final Locale selectedLocale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Color(0xFFE9E7E2)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.language, color: EtSiTheme.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, 'Langue de l’application'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    tr(context, 'Choisis la langue de ton interface'),
                    style: TextStyle(color: EtSiTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            DropdownButton<Locale>(
              value: selectedLocale,
              underline: SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: Locale('fr'),
                  child: Text(tr(context, 'Français')),
                ),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
              ],
              onChanged: (locale) {
                if (locale != null) onChanged(locale);
              },
            ),
          ],
        ),
      ),
    );
  }
}
