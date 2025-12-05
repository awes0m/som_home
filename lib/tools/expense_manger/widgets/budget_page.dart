import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Budgets")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final b in c.data.budgets)
            Card(
              child: ListTile(
                title: Text("${b.category} – Limit: ₹${b.limit}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Spent: ₹${c.budgetSpent(b.category)}"),
                    LinearProgressIndicator(
                      value: c.budgetPercent(b),
                      backgroundColor: Colors.grey.shade300,
                      color: c.budgetPercent(b) < 0.8
                          ? Colors.green
                          : c.budgetPercent(b) < 1
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _addBudgetDialog(context),
            child: const Text("Add Budget"),
          ),
        ],
      ),
    );
  }

  void _addBudgetDialog(BuildContext context) {
    final category = TextEditingController();
    final limit = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Budget"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Category"), controller: category),
            TextField(decoration: const InputDecoration(labelText: "Limit ₹"), controller: limit, keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<AppController>().addBudget(
                    category.text,
                    double.tryParse(limit.text) ?? 0,
                  );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
