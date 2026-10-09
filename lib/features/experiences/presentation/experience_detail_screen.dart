import '../../../app/translations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../data/experience_repository.dart';
import '../domain/experience.dart';
import '../domain/experience_validator.dart';

class ExperienceDetailScreen extends ConsumerStatefulWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  ConsumerState<ExperienceDetailScreen> createState() =>
      _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState
    extends ConsumerState<ExperienceDetailScreen> {
  late final TextEditingController _reflection;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reflection = TextEditingController(text: widget.experience.reflection);
  }

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(ExperienceStatus status) async {
    if (status == ExperienceStatus.completed) {
      final error = ExperienceValidator.reflection(_reflection.text);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr(context, error))));
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final repository = ref.read(experienceRepositoryProvider);

      if (status == ExperienceStatus.completed) {
        await repository.saveReflection(widget.experience.id, _reflection.text);
      }

      await repository.updateStatus(widget.experience.id, status);

      if (mounted) {
        final prefix = Localizations.localeOf(context).languageCode == 'en'
            ? 'Status'
            : 'Statut';
        final statusLabel = tr(context, status.label).toLowerCase();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$prefix: $statusLabel.')));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'Modification impossible. Réessaie.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveReflection() async {
    final error = ExperienceValidator.reflection(_reflection.text);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr(context, error))));
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(experienceRepositoryProvider)
          .saveReflection(widget.experience.id, _reflection.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'Bilan enregistré.'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'Enregistrement impossible.'))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(context, 'Supprimer cette expérience ?')),
        content: Text(
          tr(
            context,
            'Cette action est définitive. Toutes les données de cette expérience seront supprimées.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr(context, 'Annuler')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr(context, 'Supprimer')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(experienceRepositoryProvider).delete(widget.experience.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'Suppression impossible. Réessaie.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final experience = widget.experience;
    final isActive = experience.status == ExperienceStatus.active;
    final isDraft = experience.status == ExperienceStatus.draft;
    final isFinished =
        experience.status == ExperienceStatus.completed ||
        experience.status == ExperienceStatus.abandoned;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Mon expérience')),
        actions: [
          IconButton(
            tooltip: tr(context, 'Supprimer'),
            onPressed: _loading ? null : _delete,
            icon: Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFEAEFFD),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              tr(context, experience.status.label),
              style: TextStyle(
                color: EtSiTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            experience.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: EtSiTheme.text,
            ),
          ),
          SizedBox(height: 12),
          Text(experience.category, style: TextStyle(color: EtSiTheme.muted)),
          if (experience.description.isNotEmpty) ...[
            SizedBox(height: 24),
            Text(
              experience.description,
              style: TextStyle(height: 1.6, fontSize: 16),
            ),
          ],
          SizedBox(height: 32),
          Text(
            tr(context, 'Ce que j’en retiens'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            tr(
              context,
              'Qu’as-tu découvert ? Qu’aimerais-tu changer la prochaine fois ?',
            ),
            style: TextStyle(color: EtSiTheme.muted, height: 1.5),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _reflection,
            maxLength: 1000,
            maxLines: 5,
            enabled: !_loading,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: tr(
                context,
                'Écris ici tes observations et tes apprentissages…',
              ),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              final error = ExperienceValidator.reflection(value);
              return error == null ? null : tr(context, error);
            },
          ),
          SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : _saveReflection,
            child: Text(tr(context, 'Enregistrer mon bilan')),
          ),
          SizedBox(height: 24),
          if (isDraft)
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _changeStatus(ExperienceStatus.active),
              child: Text(tr(context, 'Démarrer cette expérience')),
            ),
          if (isActive) ...[
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _changeStatus(ExperienceStatus.completed),
              child: Text(tr(context, 'Terminer et faire le bilan')),
            ),
            SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _changeStatus(ExperienceStatus.abandoned),
              child: Text(tr(context, 'Abandonner cette expérience')),
            ),
          ],
          if (isFinished)
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _changeStatus(ExperienceStatus.active),
              child: Text(tr(context, 'Reprendre cette expérience')),
            ),
          if (_loading) ...[
            SizedBox(height: 16),
            Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
