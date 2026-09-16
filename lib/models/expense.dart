import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum ExpenseCategory { food, vet, grooming, supplies, medication, other }

ExpenseCategory expenseCategoryFrom(String? v) {
  return ExpenseCategory.values.firstWhere(
    (e) => e.name == v,
    orElse: () => ExpenseCategory.other,
  );
}

class Expense {
  final String id;
  final String petId;
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String notes;

  Expense({
    String? id,
    required this.petId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'title': title,
        'category': category.name,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as String,
        petId: m['petId'] as String,
        title: (m['title'] as String?) ?? '',
        category: expenseCategoryFrom(m['category'] as String?),
        amount: ((m['amount'] as num?) ?? 0).toDouble(),
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        notes: (m['notes'] as String?) ?? '',
      );
}