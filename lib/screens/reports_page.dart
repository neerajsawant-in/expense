import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/entry.dart';
import '../models/report_range.dart';
import '../state/tracker_store.dart';
import '../theme.dart';
import '../widgets/app_components.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.store});
  final TrackerStore store;
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportRange range = ReportRange.month;
  bool saving = false;
  List<ExpenseEntry> get reportEntries {
    final now = DateTime.now();
    return widget.store.entries
        .where(
          (e) =>
              !e.date.isBefore(range.start(now)) &&
              e.date.isBefore(range.end(now)),
        )
        .toList();
  }

  List<ExpenseEntry> get expenses =>
      reportEntries.where((e) => e.kind == EntryKind.expense).toList();
  Map<String, double> get categories => widget.store.categoryTotals(expenses);
  double get total => widget.store.sumFor(expenses);

  @override
  Widget build(BuildContext context) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final date = DateTime.now();
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const PageHeader(
          'Reports',
          subtitle: 'A shareable snapshot of your money',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: SegmentedButton<ReportRange>(
            segments: ReportRange.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {range},
            onSelectionChanged: (s) => setState(() => range = s.first),
            showSelectedIcon: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF19372D), Color(0xFF10231D)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  range.title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFB5D4C6),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Text(
                      '${expenses.length} expenses',
                      style: const TextStyle(
                        color: Color(0xFFCAE0D5),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${sorted.length} categories',
                      style: const TextStyle(
                        color: Color(0xFFCAE0D5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
          child: Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Money lent',
                  value: money(widget.store.lent),
                  icon: Icons.south_west_rounded,
                  color: green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Money owed',
                  value: money(widget.store.borrowed),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFEB9760),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Category breakdown'),
        if (sorted.isEmpty)
          const EmptyState(
            title: 'No spending to report',
            message: 'Add expenses in this period to build your report.',
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              children: sorted.map((item) {
                final cat = ExpenseCategory.fromName(item.key);
                final share = total == 0 ? 0.0 : item.value / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Icon(cat.icon, color: cat.color, size: 18),
                      const SizedBox(width: 9),
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
                        '${(share * 100).round()}%',
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
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
                );
              }).toList(),
            ),
          ),
        const SectionTitle('Included activity'),
        if (reportEntries.isEmpty)
          const EmptyState(
            title: 'No activity in this period',
            message: 'Your report will fill in as you add entries.',
          )
        else
          ...reportEntries.take(12).map((e) => EntryTile(entry: e)),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: SizedBox(
            height: 53,
            child: FilledButton.icon(
              onPressed: saving ? null : _download,
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                saving ? 'Preparing report…' : 'Download PDF report',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 9, 25, 0),
          child: Text(
            'Includes totals, category percentages, lending balances, and all activity in the selected period. Generated ${date.day}/${date.month}/${date.year}.',
            style: const TextStyle(color: muted, fontSize: 10, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _download() async {
    setState(() => saving = true);
    try {
      final bytes = await _buildPdf();
      final now = DateTime.now();
      await FileSaver.instance.saveFile(
        name:
            'Neeraj_Expense_${range.name}_${now.year}_${now.month.toString().padLeft(2, '0')}',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your PDF report is ready to save.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the report: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();
    final now = DateTime.now();
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dateLabel =
        '${range.start(now).day}/${range.start(now).month}/${range.start(now).year} - ${range.end(now).subtract(const Duration(days: 1)).day}/${range.end(now).subtract(const Duration(days: 1)).month}/${range.end(now).subtract(const Duration(days: 1)).year}';
    final entries = reportEntries;
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#19372D'),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NEERAJ EXPENSE · MONEY REPORT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  range.title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  dateLabel,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#CAE0D5'),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            children: [
              _pdfMetric('Total spent', 'INR ${total.toStringAsFixed(2)}'),
              _pdfMetric('Transactions', '${expenses.length}'),
              _pdfMetric(
                range == ReportRange.year ? 'Monthly average' : 'Daily average',
                'INR ${(total / (range == ReportRange.week
                        ? 7
                        : range == ReportRange.month
                        ? now.day
                        : 12)).toStringAsFixed(2)}',
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Category breakdown',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (sorted.isEmpty)
            pw.Text(
              'No expense records in this period.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ...sorted.map(_pdfCategoryRow),
          pw.SizedBox(height: 18),
          pw.Text(
            'Money with people',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _pdfMetric(
                'Owed to you',
                'INR ${widget.store.lent.toStringAsFixed(2)}',
              ),
              _pdfMetric(
                'You owe',
                'INR ${widget.store.borrowed.toStringAsFixed(2)}',
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Recent activity',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (entries.isEmpty)
            pw.Text(
              'No records in this period.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ...entries.map(_pdfEntryRow),
          pw.SizedBox(height: 16),
          pw.Text(
            'Generated by Neeraj Expense · Your records are stored on this device.',
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
          ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _pdfMetric(String label, String value) => pw.Expanded(
    child: pw.Container(
      margin: const pw.EdgeInsets.only(right: 7),
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0F5F1'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  pw.Widget _pdfCategoryRow(MapEntry<String, double> item) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 7),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey300, width: .5),
      ),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(item.key, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Text(
          '${(item.value / (total == 0 ? 1 : total) * 100).toStringAsFixed(1)}%',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(width: 18),
        pw.Text(
          'INR ${item.value.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );

  pw.Widget _pdfEntryRow(ExpenseEntry entry) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey300, width: .5),
      ),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            entry.title,
            maxLines: 1,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            entry.kind == EntryKind.expense ? entry.category : entry.person,
            maxLines: 1,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        pw.SizedBox(
          width: 46,
          child: pw.Text(
            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        pw.SizedBox(
          width: 76,
          child: pw.Text(
            'INR ${entry.amount.toStringAsFixed(2)}',
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}
