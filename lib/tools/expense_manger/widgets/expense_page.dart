import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/recurring.dart';
import 'expense_table.dart';
import 'summary_cards.dart';
import 'charts.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Generate recurring transactions on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().generateRecurringIfDue();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppController>();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Budget'),
            Tab(text: 'Recurring'),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 250, // Adjust for app bar and tabs
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Expenses Tab
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCards(),
                    SizedBox(height: 20),
                    ExpenseTable(),
                    SizedBox(height: 30),
                    ChartsSection(),
                  ],
                ),
              ),
              // Budget Tab
              BudgetContent(),
              // Recurring Tab
              RecurringContent(),
            ],
          ),
        ),
      ],
    );
  }
}

// Budget Content without Scaffold
class BudgetContent extends StatelessWidget {
  const BudgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    return ListView(
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

// Recurring Content without Scaffold
class RecurringContent extends StatelessWidget {
  const RecurringContent({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    return ListView(
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
