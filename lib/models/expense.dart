class Expense {
  final String id;
  final String userId;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final String? receipt;
  final String status; // 'pending', 'approved', 'rejected'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    this.receipt,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      receipt: json['receipt'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'receipt': receipt,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? description,
    String? category,
    double? amount,
    DateTime? date,
    String? receipt,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      receipt: receipt ?? this.receipt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Expense{id: $id, description: $description, amount: $amount, status: $status}';
  }
}