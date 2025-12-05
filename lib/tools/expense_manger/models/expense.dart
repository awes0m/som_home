
class Expense {
  String date; // YYYY-MM-DD
  String description;
  String category;
  String type; // "income" / "expense"
  double amount;

  Expense({
    required this.date,
    this.description = "",
    this.category = "",
    this.type = "expense",
    this.amount = 0,
  });

  Map<String, dynamic> toJson() => {
        "date": date,
        "description": description,
        "category": category,
        "type": type,
        "amount": amount,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        date: json["date"],
        description: json["description"],
        category: json["category"],
        type: json["type"],
        amount: (json["amount"] ?? 0).toDouble(),
      );
}
