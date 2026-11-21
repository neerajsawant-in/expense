import 'package:material_ui/material_ui.dart';

import '../state/tracker_store.dart';
import '../theme.dart';
import '../widgets/app_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.store, required this.name});
  final TrackerStore store;
  final String name;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController budget;
  @override
  void initState() {
    super.initState();
    budget = TextEditingController(
      text: widget.store.monthlyBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 30),
    children: [
      const PageHeader(
        'Settings',
        subtitle: 'Make Neeraj Expense fit your routine',
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F4EC),
              child: Icon(Icons.person_rounded, color: green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Local profile · sign-in not connected',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SectionTitle('Monthly spending budget'),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set a monthly target to see how you’re tracking on the dashboard.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: budget,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                filled: true,
                fillColor: canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(backgroundColor: ink),
                child: const Text('Save budget'),
              ),
            ),
          ],
        ),
      ),
      const SectionTitle('About your data'),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(19),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.phone_iphone_rounded,
              title: 'Stored on this device',
              body: 'Your entries and budget stay in local app storage.',
            ),
            Divider(height: 25),
            _InfoRow(
              icon: Icons.lock_outline_rounded,
              title: 'Accounts are not connected yet',
              body: 'Email, Google and GitHub sign-in need an authentication service and provider credentials before they can protect or sync accounts.',
            ),
          ],
        ),
      ),
    ],
  );
  Future<void> _save() async {
    final parsed = double.tryParse(budget.text.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a budget greater than zero.')),
      );
      return;
    }
    await widget.store.setBudget(parsed);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Monthly budget saved.')));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: green, size: 19),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(color: muted, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    ],
  );
}
