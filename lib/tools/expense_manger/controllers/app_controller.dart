import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/storage/firebase_storage_service.dart';
import '../models/app_data.dart';
import '../models/budget.dart';
import '../models/recurring.dart';
import '../models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class AppController extends ChangeNotifier {
  AppData data = AppData(expenses: [], bankBalance: 0);

  //----------------------------------------------
  // BUDGETS
  //----------------------------------------------

  void addBudget(String category, double limit) {
    data.budgets.add(Budget(category: category, limit: limit));
    notifyListeners();
  }

  double budgetSpent(String category) {
    return data.expenses
        .where((e) => e.category == category && e.type == "expense")
        .fold(0, (s, e) => s + e.amount);
  }

  double budgetPercent(Budget b) {
    final spent = budgetSpent(b.category);
    return spent / b.limit;
  }

  //----------------------------------------------
  // RECURRING TRANSACTIONS
  //----------------------------------------------

  void addRecurring(RecurringRule rule) {
    data.recurring.add(rule);
    notifyListeners();
  }

  void generateRecurringIfDue() {
    final today = DateTime.now();

    for (final r in data.recurring) {
      final next = DateTime.parse(r.nextDate);

      if (!today.isBefore(next)) {
        // Add a transaction
        data.expenses.add(
          Expense(
            date: r.nextDate,
            description: r.description,
            category: r.category,
            type: r.type,
            amount: r.amount,
          ),
        );

        // Schedule next date
        DateTime newDate;

        switch (r.frequency) {
          case "daily":
            newDate = next.add(const Duration(days: 1));
            break;
          case "weekly":
            newDate = next.add(const Duration(days: 7));
            break;
          case "monthly":
            newDate = DateTime(next.year, next.month + 1, next.day);
            break;
          case "yearly":
            newDate = DateTime(next.year + 1, next.month, next.day);
            break;
          default:
            newDate = next;
        }

        r.nextDate = newDate.toIso8601String().split("T")[0];
      }
    }

    notifyListeners();
  }

  //----------------------------------------------
  // CSV EXPORT
  //----------------------------------------------

  Future<String> exportCSV() async {
    final buffer = StringBuffer();

    buffer.writeln("Date,Description,Category,Type,Amount");

    for (final e in data.expenses) {
      buffer.writeln(
        "${e.date},${e.description},${e.category},${e.type},${e.amount}",
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/expenses_export.csv");
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  //----------------------------------------------
  // EXPENSES: Same as before (add/update/delete)
  //----------------------------------------------

  void addExpense() {
    final today = DateTime.now().toIso8601String().split("T")[0];
    data.expenses.add(Expense(date: today));
    notifyListeners();
  }

  void updateExpense(int index, String field, dynamic value) {
    final e = data.expenses[index];
    switch (field) {
      case "date":
        e.date = value;
        break;
      case "description":
        e.description = value;
        break;
      case "category":
        e.category = value;
        break;
      case "type":
        e.type = value;
        break;
      case "amount":
        e.amount = double.tryParse(value.toString()) ?? 0;
        break;
    }
    notifyListeners();
  }

  void deleteExpense(int index) {
    data.expenses.removeAt(index);
    notifyListeners();
  }

  // ---------------- SUMMARY ----------------
  double get totalIncome => data.expenses
      .where((e) => e.type == "income")
      .fold(0, (s, e) => s + e.amount);

  double get totalExpense => data.expenses
      .where((e) => e.type == "expense")
      .fold(0, (s, e) => s + e.amount);

  double get netBalance => totalIncome - totalExpense;

  double runningBalance(int index) {
    double balance = data.bankBalance;
    for (int i = 0; i <= index; i++) {
      final e = data.expenses[i];
      balance += e.type == "income" ? e.amount : -e.amount;
    }
    return balance;
  }

  // ---------------- THEME ----------------
  void toggleTheme() {
    data.darkTheme = !data.darkTheme;
    notifyListeners();
  }

  // ---------------- SAVE / LOAD LOCAL ----------------
  Future<void> saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("expenseData", jsonEncode(data.toJson()));
  }

  Future<void> loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("expenseData")) return;

    data = AppData.fromJson(jsonDecode(prefs.getString("expenseData")!));
    generateRecurringIfDue(); // Generate recurring transactions if due
    notifyListeners();
  }

  // ---------------- FIREBASE SAVE / LOAD ----------------
  Future<String?> saveToFirebase(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final url = await FirebaseStorageService.saveExpenseData(user.uid, data.toJson());
      return url;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save to Firebase: $e')),
      );
      return null;
    }
  }

  Future<void> loadFromFirebase(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final loadedData = await FirebaseStorageService.loadExpenseData(user.uid);
      if (loadedData != null) {
        data = AppData.fromJson(loadedData);
        generateRecurringIfDue(); // Generate recurring transactions if due
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data loaded from Firebase')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved data found in Firebase')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load from Firebase: $e')),
      );
    }
  }

  // ---------------- EXPORT / IMPORT ----------------
  Future<void> exportToFirebase(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create CSV content
      final buffer = StringBuffer();
      buffer.writeln("Date,Description,Category,Type,Amount");

      for (final e in data.expenses) {
        buffer.writeln("${e.date},${e.description},${e.category},${e.type},${e.amount}");
      }

      final csvContent = buffer.toString();
      final downloadUrl = await FirebaseStorageService.exportToFirebase(user.uid, csvContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to Firebase successfully!\nDownload URL: $downloadUrl')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> exportToLocalFile(BuildContext context) async {
    try {
      final filePath = await exportCSV();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> importFromFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final jsonString = utf8.decode(bytes);

        if (result.files.single.extension == 'json') {
          final importedData = jsonDecode(jsonString);
          data = AppData.fromJson(importedData);
        } else if (result.files.single.extension == 'csv') {
          // Handle CSV import (simplified version)
          final lines = jsonString.split('\n');
          if (lines.isNotEmpty) {
            lines.removeAt(0); // Remove header
            data.expenses.clear();
            for (final line in lines) {
              if (line.trim().isEmpty) continue;
              final parts = line.split(',');
              if (parts.length >= 5) {
                try {
                  data.expenses.add(Expense(
                    date: parts[0],
                    description: parts[1],
                    category: parts[2],
                    type: parts[3],
                    amount: double.parse(parts[4]),
                  ));
                } catch (e) {
                  // Skip invalid rows
                }
              }
            }
          }
        }

        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
