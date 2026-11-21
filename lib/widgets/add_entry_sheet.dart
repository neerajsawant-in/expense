import 'package:material_ui/material_ui.dart';

import '../models/entry.dart';
import '../theme.dart';

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key});
  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  EntryKind kind = EntryKind.expense;
  String category = ExpenseCategory.all.first.name;
  DateTime date = DateTime.now();
  final title = TextEditingController(),
      amount = TextEditingController(),
      person = TextEditingController(),
      note = TextEditingController();
  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    person.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 13, 22, 25),
        decoration: const BoxDecoration(
          color: canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D9D3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add an entry',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children:
                    [
                          (EntryKind.expense, 'Spent'),
                          (EntryKind.lent, 'Lent'),
                          (EntryKind.borrowed, 'Borrowed'),
                          (EntryKind.repaid, 'Returned'),
                          (EntryKind.paidBack, 'Paid back'),
                        ]
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item.$2),
                            selected: kind == item.$1,
                            onSelected: (_) => setState(() => kind = item.$1),
                            selectedColor: const Color(0xFFDDF3E8),
                            labelStyle: TextStyle(
                              color: kind == item.$1 ? ink : muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                              side: BorderSide.none,
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 13),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _dec('Amount in ₹', Icons.currency_rupee_rounded),
              ),
              const SizedBox(height: 10),
              if (kind == EntryKind.expense) ...[
                TextField(
                  controller: title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dec(
                    'What did you spend on? (title)',
                    Icons.edit_note_rounded,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: _dec('Category', Icons.category_outlined),
                  items: ExpenseCategory.all
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => category = value ?? ExpenseCategory.all.last.name,
                  ),
                ),
              ] else ...[
                TextField(
                  controller: person,
                  textCapitalization: TextCapitalization.words,
                  decoration: _dec(switch (kind) {
                    EntryKind.lent => 'Who did you lend to?',
                    EntryKind.borrowed ||
                    EntryKind.paidBack => 'Who lent you money?',
                    _ => 'Who returned money?',
                  }, Icons.person_outline_rounded),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dec('Title (optional)', Icons.edit_note_rounded),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: note,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec('Note (optional)', Icons.notes_rounded),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Date: ${date.day}/${date.month}/${date.year}'),
                style: OutlinedButton.styleFrom(foregroundColor: ink),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save entry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (chosen != null) setState(() => date = chosen);
  }

  void _submit() {
    final value = double.tryParse(amount.text.replaceAll(',', ''));
    if (value == null || value <= 0) {
      return _error('Enter an amount greater than zero.');
    }
    if (kind == EntryKind.expense && title.text.trim().isEmpty) {
      return _error('Add a title for this expense.');
    }
    if (kind != EntryKind.expense && person.text.trim().isEmpty) {
      return _error('Add the person connected to this entry.');
    }
    Navigator.pop(
      context,
      ExpenseEntry(
        kind: kind,
        amount: value,
        title: title.text.trim().isEmpty ? kind.label : title.text.trim(),
        category: kind == EntryKind.expense ? category : kind.label,
        person: person.text.trim(),
        note: note.text.trim(),
        date: date,
      ),
    );
  }

  void _error(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 19),
    filled: true,
    fillColor: card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  );
}
