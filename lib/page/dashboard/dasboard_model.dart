class Expense {
  final int id;
  final int amount;
  final String category;
  final String note;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  /// API JSON -> Expense object.
  /// Change the keys on the right side if your backend names them differently.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0, // handles 500 and 500.0
      category: json['category']?.toString() ?? 'Other',
      note: json['note']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Expense object -> JSON (for add / update API calls).
  /// Date is sent as yyyy-MM-dd.
  Map<String, dynamic> toJson() {
    final d = date;
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date':
          '${d.year}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}',
    };
  }
}
