import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/experience.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final experienceRepositoryProvider = Provider<ExperienceRepository>(
  (ref) =>
      ExperienceRepository(ref.watch(firestoreProvider), FirebaseAuth.instance),
);

class ExperienceRepository {
  ExperienceRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Tu dois être connecté pour accéder aux expériences.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('experiences');
  }

  Stream<List<Experience>> watchExperiences() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Experience.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<String> create({
    required String title,
    required String description,
    required String category,
    required bool startImmediately,
  }) async {
    final now = Timestamp.fromDate(DateTime.now());

    final document = await _collection.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'status': startImmediately ? 'active' : 'draft',
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': startImmediately ? now : null,
      'completedAt': null,
      'reflection': '',
    });

    return document.id;
  }

  Future<void> updateStatus(String id, ExperienceStatus status) async {
    final updates = <String, dynamic>{'status': status.name};

    if (status == ExperienceStatus.active) {
      updates['startedAt'] = Timestamp.fromDate(DateTime.now());
      updates['completedAt'] = null;
    } else if (status == ExperienceStatus.completed) {
      updates['completedAt'] = Timestamp.fromDate(DateTime.now());
    } else if (status == ExperienceStatus.abandoned) {
      updates['completedAt'] = null;
    }

    await _collection.doc(id).update(updates);
  }

  Future<void> saveReflection(String id, String reflection) async {
    await _collection.doc(id).update({'reflection': reflection.trim()});
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
