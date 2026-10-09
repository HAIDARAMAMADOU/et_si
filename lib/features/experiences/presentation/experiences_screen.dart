import '../../../app/translations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../data/experience_repository.dart';
import '../domain/experience.dart';

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(experienceRepositoryProvider).watchExperiences();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(context, 'ET SI ?'),
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: tr(context, 'Mon profil'),
            onPressed: () => context.go('/profile'),
            icon: Icon(Icons.person_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/experiences/new'),
        icon: Icon(Icons.add),
        label: Text(tr(context, 'Nouvelle idée')),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Experience>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 42),
                      SizedBox(height: 12),
                      Text(
                        tr(context, 'Impossible de charger tes expériences.'),
                      ),
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(experienceRepositoryProvider),
                        child: Text(tr(context, 'Réessayer')),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final experiences = snapshot.data ?? [];
            final active = experiences
                .where((e) => e.status == ExperienceStatus.active)
                .length;
            final completed = experiences
                .where((e) => e.status == ExperienceStatus.completed)
                .length;

            return ListView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                Text(
                  tr(context, 'Et si tu essayais ?'),
                  style: TextStyle(
                    color: EtSiTheme.text,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  tr(
                    context,
                    'Chaque petite expérience peut t’apprendre quelque chose.',
                  ),
                  style: TextStyle(color: EtSiTheme.muted, height: 1.5),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: tr(context, 'En cours'),
                        value: '$active',
                        icon: Icons.bolt_outlined,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: tr(context, 'Terminées'),
                        value: '$completed',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr(context, 'Tes expériences'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: EtSiTheme.text,
                        ),
                      ),
                    ),
                    Text(
                      '${experiences.length}',
                      style: TextStyle(color: EtSiTheme.muted),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                if (experiences.isEmpty)
                  const _EmptyState()
                else
                  ...experiences.map(
                    (experience) => _ExperienceTile(experience: experience),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE9E7E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: EtSiTheme.primary, size: 24),
          SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: EtSiTheme.text,
            ),
          ),
          Text(label, style: TextStyle(color: EtSiTheme.muted)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, size: 44, color: EtSiTheme.primary),
          SizedBox(height: 14),
          Text(
            tr(context, 'Ta première idée commence ici.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          SizedBox(height: 8),
          Text(
            tr(
              context,
              'Choisis quelque chose que tu aimerais essayer, même pendant quelques minutes.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: EtSiTheme.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Color(0xFFE9E7E2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          experience.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(experience.category),
              SizedBox(height: 8),
              Text(
                tr(context, experience.status.label),
                style: TextStyle(
                  color: EtSiTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () =>
            context.push('/experiences/${experience.id}', extra: experience),
      ),
    );
  }
}
