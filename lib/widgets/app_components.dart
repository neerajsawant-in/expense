import 'package:material_ui/material_ui.dart';

import '../models/entry.dart';
import '../theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.caption,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  final String? caption;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 13),
        Text(
          value,
          style: const TextStyle(
            color: ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 22, 22, 11),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, this.onDelete});
  final ExpenseEntry entry;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.fromName(entry.category);
    final isOut =
        entry.kind == EntryKind.expense ||
        entry.kind == EntryKind.lent ||
        entry.kind == EntryKind.paidBack;
    final tint = entry.kind == EntryKind.expense
        ? category.color
        : entry.kind == EntryKind.borrowed || entry.kind == EntryKind.repaid
        ? green
        : const Color(0xFFEB9760);
    final icon = entry.kind == EntryKind.expense
        ? category.icon
        : switch (entry.kind) {
            EntryKind.lent => Icons.south_west_rounded,
            EntryKind.borrowed => Icons.north_east_rounded,
            EntryKind.expense => category.icon,
            EntryKind.repaid || EntryKind.paidBack => Icons.sync_alt_rounded,
          };
    final title = entry.kind == EntryKind.expense
        ? entry.title
        : '${entry.kind.label} · ${entry.person}';
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.kind == EntryKind.expense
                      ? entry.category
                      : entry.note.isEmpty
                      ? entry.kind.label
                      : entry.note} · ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isOut ? '−' : '+'}${money(entry.amount)}',
            style: TextStyle(
              color: isOut ? ink : green,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: muted,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 22),
    padding: const EdgeInsets.all(25),
    width: double.infinity,
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(Icons.auto_awesome_rounded, color: green, size: 30),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    ),
  );
}
