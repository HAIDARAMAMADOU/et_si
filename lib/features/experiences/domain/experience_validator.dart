class ExperienceValidator {
  static String? title(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Le titre est obligatoire.';
    if (text.length > 80) {
      return 'Le titre ne doit pas dépasser 80 caractères.';
    }

    return null;
  }

  static String? description(String? value) {
    if ((value?.trim().length ?? 0) > 500) {
      return 'La description ne doit pas dépasser 500 caractères.';
    }
    return null;
  }

  static String? reflection(String? value) {
    if ((value?.trim().length ?? 0) > 1000) {
      return 'Le bilan ne doit pas dépasser 1 000 caractères.';
    }
    return null;
  }

  static const categories = [
    'Apprentissage',
    'Bien-être',
    'Créativité',
    'Relations',
    'Projet personnel',
    'Autre',
  ];
}
