class Expense {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final String status;
  final String? notes;

  Expense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.status,
    this.notes,
  });

  // Create a copy with some fields changed
  Expense copyWith({
    String? id,
    String? description,
    String? category,
    double? amount,
    DateTime? date,
    String? status,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
    };
    print('Creating expense map: $map');
    return map;
  }

  // Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
    );
  }

  // Create from Map (Supabase)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
    );
  }

  // Helper getters
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: $formattedAmount)';
  }
}