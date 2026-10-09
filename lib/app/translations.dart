import 'package:flutter/material.dart';

const Map<String, String> _englishTranslations = {
  'Apprentissage': 'Learning',
  'Bien-être': 'Well-being',
  'Créativité': 'Creativity',
  'Relations': 'Relationships',
  'Projet personnel': 'Personal project',
  'Autre': 'Other',
  'Le titre est obligatoire.': 'A title is required.',
  'Le titre ne doit pas dépasser 80 caractères.':
      'The title must not exceed 80 characters.',
  'La description ne doit pas dépasser 500 caractères.':
      'The description must not exceed 500 characters.',
  'Le bilan ne doit pas dépasser 1 000 caractères.':
      'The reflection must not exceed 1,000 characters.',
  'Adresse e-mail invalide.': 'Invalid email address.',
  'Aucun compte ne correspond à cette adresse.':
      'No account matches this email address.',
  'Mot de passe incorrect.': 'Incorrect password.',
  'Adresse e-mail ou mot de passe incorrect.':
      'Incorrect email address or password.',
  'Cette adresse e-mail est déjà utilisée.':
      'This email address is already in use.',
  'Choisis un mot de passe plus robuste.': 'Choose a stronger password.',
  'Connexion impossible. Vérifie ton réseau.':
      'Unable to connect. Check your network.',
  'Une erreur est survenue. Réessaie.':
      'Something went wrong. Please try again.',
  'Et si tu essayais ?': 'What if you tried?',
  'Transforme tes idées en petites expériences. Essaie, observe et découvre ce que tu peux apprendre.': 'Turn your ideas into small experiments. Try, observe, and discover what you can learn.',
  'Créer mon compte': 'Create my account',
  'J’ai déjà un compte': 'I already have an account',
  'Content de te revoir.': 'Welcome back.',
  'Connecte-toi pour reprendre tes expériences.':
      'Sign in to pick up where you left off.',
  'Adresse e-mail': 'Email address',
  'Saisis une adresse e-mail valide.': 'Enter a valid email address.',
  'Mot de passe': 'Password',
  'Afficher le mot de passe': 'Show password',
  'Masquer le mot de passe': 'Hide password',
  'Saisis ton mot de passe.': 'Enter your password.',
  'Mot de passe oublié ?': 'Forgot password?',
  'Se connecter': 'Sign in',
  'Créer un compte': 'Create an account',
  'Tout commence par un essai.': 'It all starts with a try.',
  'Crée ton compte et donne une chance à tes idées.':
      'Create your account and give your ideas a chance.',
  'Au moins 6 caractères': 'At least 6 characters',
  'Le mot de passe doit contenir 6 caractères minimum.':
      'Your password must be at least 6 characters long.',
  'Confirmer le mot de passe': 'Confirm password',
  'Les mots de passe ne correspondent pas.': 'Passwords do not match.',
  'Vérifie ta boîte mail.': 'Check your inbox.',
  'Si un compte correspond à cette adresse, tu recevras les instructions de réinitialisation.': 'If an account matches this address, you will receive reset instructions.',
  'Retour à la connexion': 'Back to sign in',
  'Un mot de passe à retrouver.': 'Let’s reset your password.',
  'Saisis ton adresse e-mail pour recevoir les instructions de réinitialisation.':
      'Enter your email address to receive reset instructions.',
  'Envoyer les instructions': 'Send instructions',
  'Se déconnecter': 'Sign out',
  'Bienvenue dans ET SI ?': 'Welcome to ET SI ?',
  'Ton espace est prêt. Nous allons maintenant construire tes premières expériences.':
      'Your space is ready. Let’s build your first experiments.',
  'Mon profil': 'My profile',
  'Nouvelle idée': 'New idea',
  'Impossible de charger tes expériences.': 'Could not load your experiments.',
  'Réessayer': 'Try again',
  'Chaque petite expérience peut t’apprendre quelque chose.':
      'Every small experiment can teach you something.',
  'En cours': 'In progress',
  'Terminées': 'Completed',
  'Tes expériences': 'Your experiments',
  'Ta première idée commence ici.': 'Your first idea starts here.',
  'Choisis quelque chose que tu aimerais essayer, même pendant quelques minutes.':
      'Choose something you would like to try, even for just a few minutes.',
  'Ton expérience a été enregistrée.': 'Your experiment has been saved.',
  'Enregistrement impossible. Réessaie.': 'Could not save. Please try again.',
  'Nouvelle expérience': 'New experiment',
  'Et si tu te lançais ?': 'What if you gave it a try?',
  'Pas besoin d’un grand plan. Commence par une idée simple.':
      'No big plan needed. Start with a simple idea.',
  'Mon idée': 'My idea',
  'Ex. : Lire 10 pages chaque soir': 'E.g. Read 10 pages every evening',
  'Comment vais-je essayer ? (facultatif)': 'How will I try it? (optional)',
  'Décris ton idée en quelques mots…': 'Describe your idea in a few words…',
  'Catégorie': 'Category',
  'Commencer maintenant': 'Start now',
  'Désactive cette option pour enregistrer un brouillon.':
      'Turn this off to save a draft.',
  'Démarrer mon expérience': 'Start my experiment',
  'Enregistrer le brouillon': 'Save draft',
  'Modification impossible. Réessaie.': 'Could not update. Please try again.',
  'Bilan enregistré.': 'Reflection saved.',
  'Enregistrement impossible.': 'Could not save.',
  'Supprimer cette expérience ?': 'Delete this experiment?',
  'Cette action est définitive. Toutes les données de cette expérience seront supprimées.':
      'This action is permanent. All data for this experiment will be deleted.',
  'Annuler': 'Cancel',
  'Supprimer': 'Delete',
  'Suppression impossible. Réessaie.': 'Could not delete. Please try again.',
  'Mon expérience': 'My experiment',
  'Ce que j’en retiens': 'What I learned',
  'Qu’as-tu découvert ? Qu’aimerais-tu changer la prochaine fois ?':
      'What did you discover? What would you change next time?',
  'Écris ici tes observations et tes apprentissages…':
      'Write your observations and learnings here…',
  'Enregistrer mon bilan': 'Save my reflection',
  'Démarrer cette expérience': 'Start this experiment',
  'Terminer et faire le bilan': 'Finish and reflect',
  'Abandonner cette expérience': 'Abandon this experiment',
  'Reprendre cette expérience': 'Resume this experiment',
  'Modifier mon prénom': 'Edit my name',
  'Nom affiché': 'Display name',
  'Ex. : Aïcha Koné': 'E.g. Aisha Kone',
  'Saisis un nom.': 'Enter a name.',
  '60 caractères maximum.': '60 characters maximum.',
  'Enregistrer': 'Save',
  'Ton profil a été mis à jour.': 'Your profile has been updated.',
  'Impossible de modifier ton profil. Réessaie.':
      'Could not update your profile. Please try again.',
  'Aucune adresse e-mail disponible.': 'No email address available.',
  'Un e-mail de réinitialisation a été envoyé.':
      'A password reset email has been sent.',
  'Envoi impossible. Réessaie plus tard.': 'Could not send. Try again later.',
  'Se déconnecter ?': 'Sign out?',
  'Tu pourras te reconnecter à tout moment.':
      'You can sign in again at any time.',
  'Adresse e-mail indisponible': 'Email address unavailable',
  'Modifier mon profil': 'Edit my profile',
  'Mon parcours': 'My journey',
  'Abandonnées': 'Abandoned',
  'Total': 'Total',
  'Langue': 'Language',
  'Compte et sécurité': 'Account and security',
  'Réinitialiser mon mot de passe': 'Reset my password',
  'Recevoir un lien par e-mail': 'Receive a link by email',
  'Fermer ta session sur cet appareil': 'Sign out on this device',
  'ET SI ? · Chaque essai compte.': 'ET SI ? · Every attempt counts.',
  'Les statistiques sont momentanément indisponibles.':
      'Statistics are temporarily unavailable.',
  'Langue de l’application': 'App language',
  'Choisis la langue de ton interface': 'Choose your interface language',
  'Français': 'French',
  'Brouillon': 'Draft',
  'Active': 'Active',
  'Abandonnée': 'Abandoned',
  'Terminée': 'Completed',
};

String tr(BuildContext context, String source) {
  final languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode != 'en') return source;
  return _englishTranslations[source] ?? source;
}
