
class RecurringRule {
  String description;
  String category;
  String type;     // "income" or "expense"
  double amount;
  String frequency; // daily, weekly, monthly, yearly
  String nextDate;  // YYYY-MM-DD

  RecurringRule({
    required this.description,
    required this.category,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.nextDate,
  });

  Map<String, dynamic> toJson() => {
        "description": description,
        "category": category,
        "type": type,
        "amount": amount,
        "frequency": frequency,
        "nextDate": nextDate,
      };

  factory RecurringRule.fromJson(Map<String, dynamic> json) => RecurringRule(
        description: json["description"],
        category: json["category"],
        type: json["type"],
        amount: (json["amount"] ?? 0).toDouble(),
        frequency: json["frequency"],
        nextDate: json["nextDate"],
      );
}
