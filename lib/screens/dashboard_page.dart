import 'package:material_ui/material_ui.dart';

import '../models/entry.dart';
import '../state/tracker_store.dart';
import '../theme.dart';
import '../widgets/app_components.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.name,
    required this.onSeeAll,
    required this.onInsights,
  });
  final TrackerStore store;
  final String name;
  final VoidCallback onSeeAll, onInsights;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                'Hey, $name 👋',
                subtitle:
                    '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}',
                trailing: CircleAvatar(
                  backgroundColor: const Color(0xFFE3F4EC),
                  child: Text(
                    name.isEmpty ? 'Y' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _spendCard(context),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'You’re owed',
                        value: money(store.lent),
                        icon: Icons.south_west_rounded,
                        color: green,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: MetricCard(
                        label: 'You owe',
                        value: money(store.borrowed),
                        icon: Icons.north_east_rounded,
                        color: const Color(0xFFEB9760),
                      ),
                    ),
                  ],
                ),
              ),
              SectionTitle(
                'Spending this week',
                trailing: TextButton(
                  onPressed: onInsights,
                  child: const Text('See insights'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _weekBars(context, store),
              ),
              SectionTitle(
                'Recent activity',
                trailing: TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See all'),
                ),
              ),
            ],
          ),
        ),
        if (store.entries.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              title: 'A fresh start',
              message: 'Add your first expense or money transfer to see your progress here.',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => EntryTile(entry: store.entries[index]),
              childCount: store.entries.length.clamp(0, 5),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _spendCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF19372D), Color(0xFF10231D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: ink.withValues(alpha: .13),
          blurRadius: 20,
          offset: const Offset(0, 9),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SPENT THIS MONTH',
          style: TextStyle(
            color: Color(0xFFB5D4C6),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 9),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            money(store.thisMonthSpend),
            key: ValueKey(store.thisMonthSpend),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: green, size: 15),
            const SizedBox(width: 6),
            Text(
              '${store.thisMonthCount} expenses',
              style: const TextStyle(color: Color(0xFFCAE0D5), fontSize: 12),
            ),
            const Spacer(),
            Text(
              '${(store.budgetPercent * 100).round()}% of budget',
              style: const TextStyle(color: Color(0xFFCAE0D5), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: store.budgetPercent.clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: .12),
            color: store.budgetPercent >= 1 ? const Color(0xFFEF9B70) : green,
          ),
        ),
      ],
    ),
  );

  Widget _weekBars(BuildContext context, TrackerStore data) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final values = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final sum = data.sumFor(
        data.entries.where(
          (e) =>
              e.kind == EntryKind.expense &&
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day,
        ),
      );
      return (day, sum);
    });
    final top = values.map((v) => v.$2).fold(0.0, (a, b) => a > b ? a : b);
    return Container(
      height: 156,
      padding: const EdgeInsets.fromLTRB(13, 15, 13, 11),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final ratio = top == 0 ? 0.05 : (v.$2 / top).clamp(.05, 1).toDouble();
          final active = v.$1.day == now.day;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  v.$2 == 0 ? '' : money(v.$2),
                  style: const TextStyle(color: muted, fontSize: 8),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  height: 80 * ratio,
                  width: 20,
                  decoration: BoxDecoration(
                    color: active ? green : const Color(0xFFDDE8E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][v.$1.weekday - 1],
                  style: TextStyle(
                    color: active ? ink : muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _weekday(int n) => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][n - 1];
  String _month(int n) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][n - 1];
}
