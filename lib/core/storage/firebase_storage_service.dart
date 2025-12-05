import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save expense data to Firebase Storage
  static Future<String> saveExpenseData(String userId, Map<String, dynamic> data) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'expenses_$timestamp.json';
      final storageRef = _storage.ref().child('users/$userId/expenses/$fileName');

      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      await storageRef.putData(bytes);

      // Return the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to save expense data to Firebase: $e');
    }
  }

  // Load latest expense data from Firebase Storage
  static Future<Map<String, dynamic>?> loadExpenseData(String userId) async {
    try {
      final storageRef = _storage.ref().child('users/$userId/expenses');

      final result = await storageRef.listAll();
      if (result.items.isEmpty) return null;

      // Get the most recent file (assuming naming convention includes timestamp)
      result.items.sort((a, b) => b.name.compareTo(a.name));
      final latestFile = result.items.first;

      final downloadUrl = await latestFile.getDownloadURL();
      final response = await _storage.refFromURL(downloadUrl).getData();

      if (response != null) {
        final jsonString = utf8.decode(response);
        return jsonDecode(jsonString);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load expense data from Firebase: $e');
    }
  }

  // Export CSV to Firebase Storage
  static Future<String> exportToFirebase(String userId, String csvContent) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'expenses_export_$timestamp.csv';
      final storageRef = _storage.ref().child('users/$userId/exports/$fileName');

      final bytes = utf8.encode(csvContent);
      await storageRef.putData(bytes);

      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to export CSV to Firebase: $e');
    }
  }

  // Import from Firebase Storage URL
  static Future<Map<String, dynamic>?> importFromFirebase(String downloadUrl) async {
    try {
      final storageRef = _storage.refFromURL(downloadUrl);
      final response = await storageRef.getData();

      if (response != null) {
        final jsonString = utf8.decode(response);
        return jsonDecode(jsonString);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to import from Firebase: $e');
    }
  }
}
