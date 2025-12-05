import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return isSmallScreen
        ? Column(
            children: [
              _card("Income", c.totalIncome, Colors.green),
              const SizedBox(height: 10),
              _card("Expense", c.totalExpense, Colors.red),
              const SizedBox(height: 10),
              _card("Balance", c.netBalance, Colors.blue),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _card("Income", c.totalIncome, Colors.green),
              _card("Expense", c.totalExpense, Colors.red),
              _card("Balance", c.netBalance, Colors.blue),
            ],
          );
  }

  Widget _card(String title, double value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 120,
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              "₹${value.toStringAsFixed(2)}",
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
