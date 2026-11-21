import 'package:material_ui/material_ui.dart';

enum EntryKind { expense, lent, borrowed, repaid, paidBack }

extension EntryKindLabels on EntryKind {
  String get key => switch (this) {
    EntryKind.expense => 'spend',
    EntryKind.lent => 'lent',
    EntryKind.borrowed => 'borrowed',
    EntryKind.repaid => 'repaid',
    EntryKind.paidBack => 'paid_back',
  };
  String get label => switch (this) {
    EntryKind.expense => 'Expense',
    EntryKind.lent => 'Money lent',
    EntryKind.borrowed => 'Money borrowed',
    EntryKind.repaid => 'Money returned to you',
    EntryKind.paidBack => 'You paid back',
  };
  static EntryKind parse(String key) => switch (key) {
    'lent' => EntryKind.lent,
    'borrowed' => EntryKind.borrowed,
    'repaid' => EntryKind.repaid,
    'paid_back' => EntryKind.paidBack,
    _ => EntryKind.expense,
  };
}

class ExpenseEntry {
  const ExpenseEntry({
    required this.kind,
    required this.amount,
    required this.title,
    required this.category,
    required this.person,
    required this.note,
    required this.date,
  });
  final EntryKind kind;
  final double amount;
  final String title, category, person, note;
  final DateTime date;

  Map<String, Object?> toJson() => {
    'kind': kind.key,
    'amount': amount,
    'title': title,
    'category': category,
    'person': person,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    final kind = EntryKindLabels.parse(json['kind'] as String? ?? 'spend');
    final category = json['category'] as String? ?? 'Other';
    final oldNote = json['note'] as String? ?? '';
    return ExpenseEntry(
      kind: kind,
      amount: (json['amount'] as num).toDouble(),
      title:
          json['title'] as String? ??
          (kind == EntryKind.expense
              ? (oldNote.trim().isEmpty ? category : oldNote)
              : kind.label),
      category: category,
      person: json['person'] as String? ?? '',
      note: json['note'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class ExpenseCategory {
  const ExpenseCategory(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;

  static const all = <ExpenseCategory>[
    ExpenseCategory(
      'Food & dining',
      Icons.restaurant_rounded,
      Color(0xFFE89C55),
    ),
    ExpenseCategory(
      'Groceries',
      Icons.local_grocery_store_rounded,
      Color(0xFF5FAE7A),
    ),
    ExpenseCategory(
      'Transport',
      Icons.directions_car_rounded,
      Color(0xFF6889D5),
    ),
    ExpenseCategory('Shopping', Icons.shopping_bag_rounded, Color(0xFF9A77C8)),
    ExpenseCategory(
      'Bills & utilities',
      Icons.receipt_long_rounded,
      Color(0xFFDB7B69),
    ),
    ExpenseCategory('Housing', Icons.home_rounded, Color(0xFF547B80)),
    ExpenseCategory('Health', Icons.favorite_rounded, Color(0xFFE27489)),
    ExpenseCategory('Entertainment', Icons.movie_rounded, Color(0xFF8B7AC5)),
    ExpenseCategory('Travel', Icons.flight_rounded, Color(0xFF479FB0)),
    ExpenseCategory('Education', Icons.school_rounded, Color(0xFFBC9A53)),
    ExpenseCategory('Personal care', Icons.spa_rounded, Color(0xFFCB7798)),
    ExpenseCategory(
      'Subscriptions',
      Icons.autorenew_rounded,
      Color(0xFF6E8AB4),
    ),
    ExpenseCategory(
      'Gifts & donations',
      Icons.card_giftcard_rounded,
      Color(0xFFCF765F),
    ),
    ExpenseCategory('Other', Icons.more_horiz_rounded, Color(0xFF829188)),
  ];

  static ExpenseCategory fromName(String name) => all.firstWhere(
    (category) => category.name == name,
    orElse: () => all.last,
  );
}
