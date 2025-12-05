import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/recurring.dart';

class RecurringPage extends StatelessWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Recurring Transactions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final r in c.data.recurring)
            Card(
              child: ListTile(
                title: Text("${r.description} – ₹${r.amount}"),
                subtitle: Text("${r.frequency} • Next: ${r.nextDate}"),
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _addRecurringDialog(context),
            child: const Text("Add Recurring Rule"),
          ),
        ],
      ),
    );
  }

  void _addRecurringDialog(BuildContext context) {
    final desc = TextEditingController();
    final cat = TextEditingController();
    final amt = TextEditingController();
    final freq = ValueNotifier("monthly");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Recurring Rule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: cat, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: amt, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
            ValueListenableBuilder(
              valueListenable: freq,
              builder: (_, v, __) => DropdownButton<String>(
                value: v,
                items: const [
                  DropdownMenuItem(value: "daily", child: Text("Daily")),
                  DropdownMenuItem(value: "weekly", child: Text("Weekly")),
                  DropdownMenuItem(value: "monthly", child: Text("Monthly")),
                  DropdownMenuItem(value: "yearly", child: Text("Yearly")),
                ],
                onChanged: (x) => freq.value = x!,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final today = DateTime.now().toIso8601String().split("T")[0];
              context.read<AppController>().addRecurring(
                    RecurringRule(
                      description: desc.text,
                      category: cat.text,
                      type: "expense",
                      amount: double.tryParse(amt.text) ?? 0,
                      frequency: freq.value,
                      nextDate: today,
                    ),
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
