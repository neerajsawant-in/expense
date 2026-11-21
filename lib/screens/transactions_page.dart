import 'package:material_ui/material_ui.dart';

import '../models/entry.dart';
import '../state/tracker_store.dart';
import '../widgets/app_components.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.store});
  final TrackerStore store;
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final list = widget.store.entries
        .where(
          (e) =>
              filter == 'All' ||
              (filter == 'Expenses' && e.kind == EntryKind.expense) ||
              (filter == 'People' && e.kind != EntryKind.expense),
        )
        .toList();
    return Column(
      children: [
        const PageHeader(
          'Activity',
          subtitle: 'Every purchase and money transfer',
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Row(
            children: ['All', 'Expenses', 'People']
                .map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(x),
                      selected: filter == x,
                      onSelected: (_) => setState(() => filter = x),
                      selectedColor: const Color(0xFFDDF3E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  title: 'Nothing here yet',
                  message: 'Your entries will appear here as you add them.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 22),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final entry = list[index];
                    return EntryTile(
                      entry: entry,
                      onDelete: () => _confirmDelete(context, entry),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text('“${entry.title}” will be removed from your records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) await widget.store.delete(entry);
  }
}
