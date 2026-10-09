import 'package:flutter_test/flutter_test.dart';
import 'package:et_si/features/experiences/domain/experience_validator.dart';

void main() {
  group('ExperienceValidator.title', () {
    test('refuse un titre nul', () {
      expect(ExperienceValidator.title(null), isNotNull);
    });

    test('refuse un titre vide', () {
      expect(ExperienceValidator.title(''), isNotNull);
    });

    test('refuse un titre composé uniquement d’espaces', () {
      expect(ExperienceValidator.title('   '), isNotNull);
    });

    test('accepte un titre valide', () {
      expect(ExperienceValidator.title('Lire chaque jour'), isNull);
    });

    test('refuse un titre de plus de 80 caractères', () {
      expect(ExperienceValidator.title('a' * 81), isNotNull);
    });

    test('accepte un titre de 80 caractères', () {
      expect(ExperienceValidator.title('a' * 80), isNull);
    });
  });

  group('ExperienceValidator.description', () {
    test('accepte une description facultative', () {
      expect(ExperienceValidator.description(null), isNull);
    });

    test('accepte une description composée uniquement d’espaces', () {
      expect(ExperienceValidator.description('   '), isNull);
    });

    test('accepte une description de 500 caractères', () {
      expect(ExperienceValidator.description('a' * 500), isNull);
    });

    test('refuse une description de plus de 500 caractères', () {
      expect(ExperienceValidator.description('a' * 501), isNotNull);
    });
  });

  group('ExperienceValidator.reflection', () {
    test('accepte un bilan vide pendant la rédaction', () {
      expect(ExperienceValidator.reflection(''), isNull);
    });

    test(
      'accepte un bilan composé uniquement d’espaces pendant la rédaction',
      () {
        expect(ExperienceValidator.reflection('   '), isNull);
      },
    );

    test('accepte un bilan de 1 000 caractères', () {
      expect(ExperienceValidator.reflection('a' * 1000), isNull);
    });

    test('refuse un bilan de plus de 1 000 caractères', () {
      expect(ExperienceValidator.reflection('a' * 1001), isNotNull);
    });
  });
}
