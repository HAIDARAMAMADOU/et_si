import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/experiences/domain/experience.dart';
import '../features/experiences/presentation/experiences_screen.dart';
import '../features/experiences/presentation/experience_form_screen.dart';
import '../features/experiences/presentation/experience_detail_screen.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/profile/presentation/profile_screen.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = AuthRefreshNotifier(auth.authStateChanges);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final location = state.matchedLocation;

      const publicRoutes = ['/'];
      const authRoutes = ['/login', '/register', '/reset'];

      if (!loggedIn &&
          !publicRoutes.contains(location) &&
          !authRoutes.contains(location)) {
        return '/';
      }

      if (loggedIn &&
          (publicRoutes.contains(location) || authRoutes.contains(location))) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ExperiencesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/experiences/new',
        builder: (context, state) => const ExperienceFormScreen(),
      ),
      GoRoute(
        path: '/experiences/:id',
        builder: (context, state) {
          final experience = state.extra;
          if (experience is! Experience ||
              experience.id != state.pathParameters['id']) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Expérience indisponible. Retourne à la liste et réessaie.',
                ),
              ),
            );
          }

          return ExperienceDetailScreen(experience: experience);
        },
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});
