import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';

class ExpenseTable extends StatelessWidget {
  const ExpenseTable({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    return Card(
      elevation: 6,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text("Date")),
              DataColumn(label: Text("Description")),
              DataColumn(label: Text("Category")),
              DataColumn(label: Text("Type")),
              DataColumn(label: Text("Amount")),
              DataColumn(label: Text("Running Bal")),
              DataColumn(label: Text("Actions")),
            ],
            rows: [
              for (int i = 0; i < c.data.expenses.length; i++)
                _row(context, c, i),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, AppController c, int i) {
    final e = c.data.expenses[i];

    return DataRow(cells: [
      DataCell(
        TextFormField(
          initialValue: e.date,
          onChanged: (v) => c.updateExpense(i, "date", v),
        ),
      ),
      DataCell(
        TextFormField(
          initialValue: e.description,
          onChanged: (v) => c.updateExpense(i, "description", v),
        ),
      ),
      DataCell(
        TextFormField(
          initialValue: e.category,
          onChanged: (v) => c.updateExpense(i, "category", v),
        ),
      ),
      DataCell(
        DropdownButton<String>(
          value: e.type,
          items: const [
            DropdownMenuItem(value: "income", child: Text("Income")),
            DropdownMenuItem(value: "expense", child: Text("Expense")),
          ],
          onChanged: (v) => c.updateExpense(i, "type", v),
        ),
      ),
      DataCell(
        TextFormField(
          initialValue: e.amount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (v) => c.updateExpense(i, "amount", v),
        ),
      ),
      DataCell(Text("₹${c.runningBalance(i).toStringAsFixed(2)}")),
      DataCell(
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => c.deleteExpense(i),
        ),
      ),
    ]);
  }
}
