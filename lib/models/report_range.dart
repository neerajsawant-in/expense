enum ReportRange { week, month, year }

extension ReportRangeLabels on ReportRange {
  String get label => switch (this) {
    ReportRange.week => 'Week',
    ReportRange.month => 'Month',
    ReportRange.year => '12 months',
  };

  String get title => switch (this) {
    ReportRange.week => 'This week',
    ReportRange.month => 'This month',
    ReportRange.year => 'Last 12 months',
  };

  DateTime start(DateTime now) => switch (this) {
    ReportRange.week => DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6)),
    ReportRange.month => DateTime(now.year, now.month, 1),
    ReportRange.year => DateTime(now.year, now.month - 11, 1),
  };

  DateTime end(DateTime now) => switch (this) {
    ReportRange.week => DateTime(now.year, now.month, now.day + 1),
    ReportRange.month => DateTime(now.year, now.month + 1, 1),
    ReportRange.year => DateTime(now.year, now.month + 1, 1),
  };
}
