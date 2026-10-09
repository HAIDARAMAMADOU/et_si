# ET SI ?

**ET SI ?** est une application Flutter bilingue (français/anglais) qui aide à transformer une idée en expérience personnelle : définir ce que l'on veut essayer, suivre sa progression, puis noter ce que l'on en retient.

## Fonctionnalités

- Création de compte, connexion et réinitialisation du mot de passe avec Firebase Authentication.
- Création et suivi d'expériences personnelles avec Cloud Firestore.
- Statuts d'expérience : brouillon, en cours, terminée ou abandonnée.
- Bilan/réflexion associé à une expérience.
- Profil utilisateur et statistiques de progression.
- Interface en français et en anglais, avec mémorisation de la langue choisie.
- Navigation déclarative avec GoRouter et état avec Riverpod.

## Technologies

- Flutter et Dart
- Firebase Core, Firebase Authentication et Cloud Firestore
- Riverpod
- GoRouter
- Shared Preferences
- flutter_test et flutter_lints

## Prérequis

- Flutter stable compatible avec la contrainte Dart indiquée dans `pubspec.yaml`.
- Git et un éditeur Flutter (par exemple VS Code ou Android Studio).
- Un projet Firebase configuré pour les plateformes visées.

Vérifier l'environnement :

```bash
flutter doctor
flutter --version
```

## Installation

1. Cloner le dépôt et entrer dans le dossier du projet :

   ```bash
   git clone <URL_DU_DEPOT>
   cd et_si
   ```

2. Installer les dépendances :

   ```bash
   flutter pub get
   ```

3. Configurer Firebase avec le projet Firebase approprié. Si FlutterFire CLI est utilisé :

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Cette commande génère notamment `lib/firebase_options.dart`. Sélectionner les plateformes réellement prises en charge par le dépôt. Ne jamais ajouter de compte de service Firebase Admin, de clé privée ou de secret serveur dans l'application Flutter.

4. Vérifier que l'application démarre :

   ```bash
   flutter run -d chrome
   ```

   Pour Android, démarrer un émulateur ou connecter un appareil puis exécuter `flutter run`.

## Configuration Firebase et sécurité

- Activer les méthodes de connexion utilisées par l'application dans Firebase Authentication.
- Créer/configurer la base Cloud Firestore.
- Déployer des règles Firestore qui limitent chaque utilisateur à ses propres données. Ne pas publier avec des règles ouvertes en lecture/écriture.
- Vérifier les domaines autorisés pour Firebase Authentication en production.
- `lib/firebase_options.dart` contient la configuration cliente générée pour les plateformes. Les clés de configuration cliente Firebase ne remplacent pas les règles de sécurité. Les identifiants privés et comptes de service ne doivent jamais être commités.
- Tester les règles Firestore dans le simulateur Firebase avant la publication.

## Tests et qualité

Exécuter les contrôles localement avant chaque pull request :

```bash
dart format lib test
flutter analyze
flutter test --reporter expanded
flutter build web --release
```

Les tests actuels couvrent notamment les limites de validation du titre, de la description et du bilan, ainsi qu'un test widget de base pour l'écran d'accueil. Ajouter des tests aux nouvelles fonctionnalités et vérifier les parcours d'authentification et Firestore sur un environnement de test avant la sortie.

## Intégration continue (GitHub Actions)

Le workflow `.github/workflows/ci.yml` s'exécute lors des pushs et pull requests vers `main`, `master` ou `develop`, ainsi que manuellement. Il installe Flutter, récupère les dépendances, vérifie le formatage, lance l'analyse statique et les tests, puis tente une compilation Web de release.

Pour que le job de compilation passe, le dépôt doit contenir les fichiers de plateforme Web et `lib/firebase_options.dart` générés/configurés pour le projet. Le workflow ne déploie pas automatiquement l'application : le déploiement doit être ajouté séparément après configuration sécurisée de l'hébergement.

## Préparer une version publiable

Avant toute publication :

1. Exécuter toutes les commandes de qualité ci-dessus et résoudre les avertissements.
2. Vérifier les règles Firestore, les fournisseurs de connexion et les domaines autorisés.
3. Confirmer la configuration de production et ne pas embarquer de secrets privés.
4. Tester les scénarios inscription, connexion, déconnexion, réinitialisation du mot de passe, création/modification/suppression d'expérience et changement de langue.
5. Vérifier l'affichage sur les tailles d'écran et navigateurs pris en charge.
6. Incrémenter `version` dans `pubspec.yaml` (version et numéro de build).
7. Produire et tester l'artefact de release :

   ```bash
   flutter build web --release
   flutter build appbundle --release
   ```

   La commande Android nécessite un environnement Android configuré et une signature de release correctement configurée. Ne commitez pas les fichiers de signature ni leurs mots de passe.

8. Publier uniquement après validation de la CI et un test manuel du build final.

## Structure principale

```text
lib/
  app/                 # Application, navigation, thème et langue
  features/
    auth/              # Authentification
    experiences/       # Modèle, validation, accès Firestore et écrans
    profile/           # Profil et préférences
  main.dart
 test/                 # Tests unitaires et widget
 .github/workflows/    # Intégration continue GitHub Actions
CHANGELOG.md           # versions documentées
```

## État du projet

Projet en cours de finalisation. La CI automatise les contrôles de qualité et la compilation Web ; la publication effective nécessite encore la configuration des environnements Firebase et des plateformes, puis une validation manuelle des builds.
