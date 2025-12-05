
import 'expense.dart';
import 'budget.dart';
import 'recurring.dart';

class AppData {
  double bankBalance;
  List<Expense> expenses;
  List<Budget> budgets;
  List<RecurringRule> recurring;
  bool darkTheme;

  AppData({
    this.bankBalance = 0,
    this.expenses = const [],
    this.budgets = const [],
    this.recurring = const [],
    this.darkTheme = true,
  });

  Map<String, dynamic> toJson() => {
        "bankBalance": bankBalance,
        "darkTheme": darkTheme,
        "expenses": expenses.map((e) => e.toJson()).toList(),
        "budgets": budgets.map((b) => b.toJson()).toList(),
        "recurring": recurring.map((r) => r.toJson()).toList(),
      };

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        bankBalance: (json["bankBalance"] ?? 0).toDouble(),
        darkTheme: json["darkTheme"] ?? true,
        expenses:
            (json["expenses"] as List).map((e) => Expense.fromJson(e)).toList(),
        budgets:
            (json["budgets"] as List).map((b) => Budget.fromJson(b)).toList(),
        recurring:
            (json["recurring"] as List).map((r) => RecurringRule.fromJson(r)).toList(),
      );
}
