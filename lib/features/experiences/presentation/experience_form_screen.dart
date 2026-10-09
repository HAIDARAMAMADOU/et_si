import '../../../app/translations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../data/experience_repository.dart';
import '../domain/experience_validator.dart';

class ExperienceFormScreen extends ConsumerStatefulWidget {
  const ExperienceFormScreen({super.key});

  @override
  ConsumerState<ExperienceFormScreen> createState() =>
      _ExperienceFormScreenState();
}

class _ExperienceFormScreenState extends ConsumerState<ExperienceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  String _category = ExperienceValidator.categories.first;
  bool _startImmediately = true;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(experienceRepositoryProvider)
          .create(
            title: _title.text,
            description: _description.text,
            category: _category,
            startImmediately: _startImmediately,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'Ton expérience a été enregistrée.')),
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'Enregistrement impossible. Réessaie.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'Nouvelle expérience'))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              Text(
                tr(context, 'Et si tu te lançais ?'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: EtSiTheme.text,
                ),
              ),
              SizedBox(height: 8),
              Text(
                tr(
                  context,
                  'Pas besoin d’un grand plan. Commence par une idée simple.',
                ),
                style: TextStyle(color: EtSiTheme.muted, height: 1.5),
              ),
              SizedBox(height: 28),
              TextFormField(
                controller: _title,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: tr(context, 'Mon idée'),
                  hintText: tr(context, 'Ex. : Lire 10 pages chaque soir'),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final error = ExperienceValidator.title(value);
                  return error == null ? null : tr(context, error);
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _description,
                maxLength: 500,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: tr(
                    context,
                    'Comment vais-je essayer ? (facultatif)',
                  ),
                  hintText: tr(context, 'Décris ton idée en quelques mots…'),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final error = ExperienceValidator.description(value);
                  return error == null ? null : tr(context, error);
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: tr(context, 'Catégorie'),
                ),
                items: ExperienceValidator.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(tr(context, category)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Commencer maintenant')),
                subtitle: Text(
                  tr(
                    context,
                    'Désactive cette option pour enregistrer un brouillon.',
                  ),
                ),
                value: _startImmediately,
                onChanged: (value) {
                  setState(() => _startImmediately = value);
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _startImmediately
                            ? tr(context, 'Démarrer mon expérience')
                            : tr(context, 'Enregistrer le brouillon'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
