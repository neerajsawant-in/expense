import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/entry.dart';
import '../models/report_range.dart';
import '../state/tracker_store.dart';
import '../theme.dart';
import '../widgets/app_components.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.store});
  final TrackerStore store;
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  ReportRange range = ReportRange.month;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entries = widget.store.expensesFor(range.start(now), range.end(now));
    final total = widget.store.sumFor(entries);
    final categoryTotals = widget.store.categoryTotals(entries);
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final avg =
        total /
        (range == ReportRange.week
            ? 7
            : range == ReportRange.month
            ? now.day
            : 12);
    final top = sorted.isEmpty ? null : sorted.first;
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const PageHeader(
          'Insights',
          subtitle: 'The story behind your spending',
        ),
        _rangeSelector(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Total spent',
                  value: money(total),
                  icon: Icons.account_balance_wallet_outlined,
                  color: green,
                  caption: range.title,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: range == ReportRange.year
                      ? 'Monthly average'
                      : 'Daily average',
                  value: money(avg),
                  icon: Icons.show_chart_rounded,
                  color: const Color(0xFF6889D5),
                  caption: range == ReportRange.year ? 'per month' : 'per day',
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Spending trend'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _trendChart(entries, range, now),
        ),
        const SectionTitle(
          'Where it goes',
          trailing: Text(
            'Share of total',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                if (sorted.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Add expenses to see your category breakdown.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 188,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: const Size(160, 160),
                            painter: _DonutPainter(
                              sorted
                                  .map(
                                    (item) => (
                                      ExpenseCategory.fromName(item.key).color,
                                      item.value,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                money(total),
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'total',
                                style: TextStyle(color: muted, fontSize: 11),
                              ),
                              if (top != null) ...[
                                const SizedBox(height: 14),
                                const Text(
                                  'Top category',
                                  style: TextStyle(color: muted, fontSize: 10),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  top.key,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${(top.value / total * 100).round()}% of spending',
                                  style: const TextStyle(
                                    color: green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ...sorted.map((item) {
                    final category = ExpenseCategory.fromName(item.key);
                    final share = total == 0 ? 0.0 : item.value / total;
                    return Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 16,
                                color: category.color,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  item.key,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${(share * 100).toStringAsFixed(share * 100 % 1 == 0 ? 0 : 1)}%',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                money(item.value),
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: share,
                              minHeight: 5,
                              color: category.color,
                              backgroundColor: category.color.withValues(
                                alpha: .12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        if (top != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EC),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${top.key} is your biggest category at ${(top.value / total * 100).round()}% of your ${range.label.toLowerCase()} spending.',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _rangeSelector() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
    child: SegmentedButton<ReportRange>(
      segments: ReportRange.values
          .map((r) => ButtonSegment(value: r, label: Text(r.label)))
          .toList(),
      selected: {range},
      onSelectionChanged: (s) => setState(() => range = s.first),
      showSelectedIcon: false,
    ),
  );
  Widget _trendChart(
    List<ExpenseEntry> entries,
    ReportRange range,
    DateTime now,
  ) {
    final values = <(String, double, bool)>[];
    if (range == ReportRange.week) {
      final today = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < 7; i++) {
        final d = today.subtract(Duration(days: 6 - i));
        values.add((
          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
          _totalForDay(entries, d),
          i == 6,
        ));
      }
    } else if (range == ReportRange.month) {
      for (var i = 0; i < 5; i++) {
        final start = i * 7 + 1;
        final end = start + 7;
        final val = widget.store.sumFor(
          entries.where((e) => e.date.day >= start && e.date.day < end),
        );
        values.add(('W${i + 1}', val, (now.day - 1) ~/ 7 == i));
      }
    } else {
      for (var i = 11; i >= 0; i--) {
        final m = DateTime(now.year, now.month - i, 1);
        final val = widget.store.sumFor(
          entries.where(
            (e) => e.date.year == m.year && e.date.month == m.month,
          ),
        );
        values.add((
          ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'][m.month -
              1],
          val,
          i == 0,
        ));
      }
    }
    final maximum = values.fold(0.0, (m, v) => math.max(m, v.$2));
    return Container(
      height: 191,
      padding: const EdgeInsets.fromLTRB(13, 18, 13, 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(range.title, style: const TextStyle(color: muted, fontSize: 11)),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((v) {
                final barHeight = maximum == 0
                    ? 4.0
                    : 76 * (v.$2 / maximum).clamp(.06, 1).toDouble();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: barHeight,
                          width: 19,
                          decoration: BoxDecoration(
                            color: v.$3 ? green : const Color(0xFFDDE8E1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          v.$1,
                          style: TextStyle(
                            color: v.$3 ? ink : muted,
                            fontSize: 9,
                            fontWeight: v.$3
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  double _totalForDay(List<ExpenseEntry> entries, DateTime d) =>
      widget.store.sumFor(
        entries.where(
          (e) =>
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day,
        ),
      );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices);
  final List<(Color, double)> slices;
  @override
  void paint(Canvas canvas, Size size) {
    final sum = slices.fold(0.0, (v, e) => v + e.$2);
    if (sum <= 0) return;
    final center = (Offset.zero & size).center;
    final radius = math.min(size.width, size.height) / 2;
    double start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = slice.$2 / sum * math.pi * 2;
      final paint = Paint()
        ..color = slice.$1
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 9),
        start,
        sweep - .025,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.slices != slices;
}
