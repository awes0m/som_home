import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/bookmark.dart';
import 'models/task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Users collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Bookmarks collection
  CollectionReference get _bookmarksCollection {
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _usersCollection.doc(userId).collection('bookmarks');
  }

  // Tasks collection
  CollectionReference get _tasksCollection {
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _usersCollection.doc(userId).collection('tasks');
  }

  // Settings document
  DocumentReference get _settingsDoc {
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _usersCollection
        .doc(userId)
        .collection('settings')
        .doc('app_settings');
  }

  // Create or update user profile
  Future<void> createUserProfile({
    required String email,
    String? displayName,
  }) async {
    if (userId == null) return;

    await _usersCollection.doc(userId).set({
      'email': email,
      'displayName': displayName ?? 'User',
      'createdAt': DateTime.now().toIso8601String(),
      'lastSignIn': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Sync bookmarks
  Future<void> syncBookmarks(List<Bookmark> bookmarks) async {
    if (userId == null) return;

    final batch = _firestore.batch();

    // Clear existing bookmarks
    final existingBookmarks = await _bookmarksCollection.get();
    for (var doc in existingBookmarks.docs) {
      batch.delete(doc.reference);
    }

    // Add new bookmarks
    for (var bookmark in bookmarks) {
      final docRef = _bookmarksCollection.doc(bookmark.id);
      batch.set(docRef, bookmark.toJson());
    }

    await batch.commit();
  }

  Future<List<Bookmark>> loadBookmarks() async {
    if (userId == null) return [];

    final snapshot = await _bookmarksCollection.get();
    return snapshot.docs
        .map((doc) => Bookmark.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sync tasks
  Future<void> syncTasks(List<Task> tasks) async {
    if (userId == null) return;

    final batch = _firestore.batch();

    // Clear existing tasks
    final existingTasks = await _tasksCollection.get();
    for (var doc in existingTasks.docs) {
      batch.delete(doc.reference);
    }

    // Add new tasks
    for (var task in tasks) {
      final docRef = _tasksCollection.doc(task.id);
      batch.set(docRef, task.toJson());
    }

    await batch.commit();
  }

  Future<List<Task>> loadTasks() async {
    if (userId == null) return [];

    final snapshot = await _tasksCollection.get();
    return snapshot.docs
        .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sync settings
  Future<void> syncSettings(Map<String, dynamic> settings) async {
    if (userId == null) return;

    await _settingsDoc.set(settings);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    if (userId == null) return {};

    final doc = await _settingsDoc.get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }
}
