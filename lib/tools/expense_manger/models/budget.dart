class Budget {
  String category;
  double limit;     // Budget limit
  double spent;     // Auto-calculated, NOT stored

  Budget({
    required this.category,
    required this.limit,
    this.spent = 0,
  });

  Map<String, dynamic> toJson() => {
        "category": category,
        "limit": limit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: json["category"],
        limit: (json["limit"] ?? 0).toDouble(),
      );
}
