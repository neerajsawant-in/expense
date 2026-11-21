import 'package:material_ui/material_ui.dart';

import '../state/tracker_store.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import 'dashboard_page.dart';
import 'insights_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'transactions_page.dart';

class TrackerShell extends StatefulWidget {
  const TrackerShell({
    super.key,
    required this.name,
    this.accountEmail,
    this.provider,
    this.onAccountAction,
  });
  final String name;
  final String? accountEmail;
  final String? provider;
  final Future<void> Function()? onAccountAction;
  @override
  State<TrackerShell> createState() => _TrackerShellState();
}

class _TrackerShellState extends State<TrackerShell> {
  final store = TrackerStore();
  int selected = 0;
  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    const destinations = <NavigationDestination>[
      NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_rounded),
        label: 'Activity',
      ),
      NavigationDestination(
        icon: Icon(Icons.insights_rounded),
        label: 'Insights',
      ),
      NavigationDestination(
        icon: Icon(Icons.description_outlined),
        label: 'Reports',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => !store.loaded
              ? const Center(child: CircularProgressIndicator(color: green))
              : Row(
                  children: [
                    if (wide)
                      NavigationRail(
                        selectedIndex: selected,
                        onDestinationSelected: (index) =>
                            setState(() => selected = index),
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: Colors.white,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.grid_view_rounded),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.receipt_long_rounded),
                            label: Text('Activity'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.insights_rounded),
                            label: Text('Insights'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.description_outlined),
                            label: Text('Reports'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings_outlined),
                            label: Text('Settings'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1050),
                        child: IndexedStack(
                          index: selected,
                          children: [
                            DashboardPage(
                              store: store,
                              name: widget.name,
                              onSeeAll: () => setState(() => selected = 1),
                              onInsights: () => setState(() => selected = 2),
                            ),
                            TransactionsPage(store: store),
                            InsightsPage(store: store),
                            ReportsPage(store: store),
                            SettingsPage(
                              store: store,
                              name: widget.name,
                              accountEmail: widget.accountEmail,
                              provider: widget.provider,
                              onAccountAction: widget.onAccountAction,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add entry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              height: 69,
              selectedIndex: selected,
              onDestinationSelected: (index) =>
                  setState(() => selected = index),
              destinations: destinations,
            ),
    );
  }

  Future<void> _add() async {
    final entry = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEntrySheet(),
    );
    if (entry != null) await store.add(entry);
  }
}
