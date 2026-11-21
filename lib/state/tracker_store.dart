import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entry.dart';

class TrackerStore extends ChangeNotifier {
  static const _entriesKey = 'penny_entries';
  static const _budgetKey = 'penny_monthly_budget';
  final List<ExpenseEntry> entries = [];
  double monthlyBudget = 50000;
  bool loaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    monthlyBudget = prefs.getDouble(_budgetKey) ?? monthlyBudget;
    final raw = prefs.getString(_entriesKey);
    if (raw != null) {
      try {
        entries
          ..clear()
          ..addAll(
            (jsonDecode(raw) as List).map((e) => ExpenseEntry.fromJson(e)),
          );
      } catch (_) {
        // Keep the locally entered records available if an older record is malformed.
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> add(ExpenseEntry entry) async {
    entries.insert(0, entry);
    await _save();
    notifyListeners();
  }

  Future<void> setBudget(double value) async {
    monthlyBudget = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, value);
    notifyListeners();
  }

  Future<void> delete(ExpenseEntry entry) async {
    entries.remove(entry);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _entriesKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  double get thisMonthSpend => sumFor(
    entries.where(
      (e) => e.kind == EntryKind.expense && _sameMonth(e.date, DateTime.now()),
    ),
  );
  double sumFor(Iterable<ExpenseEntry> source) =>
      source.fold(0, (sum, entry) => sum + entry.amount);
  int get thisMonthCount => entries
      .where(
        (e) =>
            e.kind == EntryKind.expense && _sameMonth(e.date, DateTime.now()),
      )
      .length;
  double get budgetPercent =>
      monthlyBudget <= 0 ? 0 : thisMonthSpend / monthlyBudget;
  double get lent => _outstanding(EntryKind.lent, EntryKind.repaid);
  double get borrowed => _outstanding(EntryKind.borrowed, EntryKind.paidBack);

  double _outstanding(EntryKind opened, EntryKind settled) {
    final balances = <String, double>{};
    for (final entry in entries.where((e) => e.kind == opened)) {
      balances[entry.person] = (balances[entry.person] ?? 0) + entry.amount;
    }
    for (final entry in entries.where((e) => e.kind == settled)) {
      balances[entry.person] = (balances[entry.person] ?? 0) - entry.amount;
    }
    return balances.values.fold(
      0,
      (sum, balance) => sum + balance.clamp(0, double.infinity),
    );
  }

  List<ExpenseEntry> expensesFor(DateTime start, DateTime end) => entries
      .where(
        (entry) =>
            entry.kind == EntryKind.expense &&
            !entry.date.isBefore(start) &&
            entry.date.isBefore(end),
      )
      .toList();

  Map<String, double> categoryTotals(Iterable<ExpenseEntry> source) {
    final totals = <String, double>{};
    for (final entry in source.where((e) => e.kind == EntryKind.expense)) {
      totals.update(
        entry.category,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }
    return totals;
  }

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
