import 'package:cloud_firestore/cloud_firestore.dart';

enum ExperienceStatus { draft, active, completed, abandoned }

extension ExperienceStatusLabel on ExperienceStatus {
  String get label => switch (this) {
    ExperienceStatus.draft => 'Brouillon',
    ExperienceStatus.active => 'En cours',
    ExperienceStatus.completed => 'Terminée',
    ExperienceStatus.abandoned => 'Abandonnée',
  };
}

class Experience {
  const Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.reflection = '',
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final ExperienceStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String reflection;

  factory Experience.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    DateTime readDate(String key) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? readOptionalDate(String key) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Experience(
      id: document.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Autre',
      status: ExperienceStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ExperienceStatus.draft,
      ),
      createdAt: readDate('createdAt'),
      startedAt: readOptionalDate('startedAt'),
      completedAt: readOptionalDate('completedAt'),
      reflection: data['reflection'] as String? ?? '',
    );
  }
}
