import 'package:flutter/material.dart';

import '../../domain/entities/reference_entities.dart';

class MonthlyPeriodSelector extends StatelessWidget {
  const MonthlyPeriodSelector({
    required this.periods,
    required this.selectedPeriodId,
    required this.onChanged,
    super.key,
  });

  final List<ReportPeriod> periods;
  final String? selectedPeriodId;
  final ValueChanged<String> onChanged;

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final monthPeriods = periods
        .where(
          (period) =>
              period.periodType == 'MONTH' && period.reportYear != null,
        )
        .toList()
      ..sort((a, b) {
        final ay = a.reportYear ?? 0;
        final by = b.reportYear ?? 0;
        if (ay != by) return ay.compareTo(by);
        final am = a.periodStart?.month ?? 0;
        final bm = b.periodStart?.month ?? 0;
        return am.compareTo(bm);
      });

    if (monthPeriods.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Periode'),
        child: Text('Belum ada periode bulanan'),
      );
    }

    final years = monthPeriods
        .map((period) => period.reportYear!)
        .toSet()
        .toList()
      ..sort();

    // Default ke bulan terbaru yang memang tersedia, bukan mengasumsikan
    // semua bulan dalam satu tahun sudah memiliki laporan.
    var selected = monthPeriods.last;
    for (final period in monthPeriods) {
      if (period.id == selectedPeriodId) {
        selected = period;
        break;
      }
    }

    final selectedYear = selected.reportYear!;
    final periodsInYear = monthPeriods
        .where((period) => period.reportYear == selectedYear)
        .toList();

    final selectedMonth =
        selected.periodStart?.month ??
        _monthFromLabel(selected.periodLabel) ??
        (periodsInYear.last.periodStart?.month ?? 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 312
            ? constraints.maxWidth
            : 312.0;

        return SizedBox(
          width: width,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                  items: [
                    for (final year in years)
                      DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      ),
                  ],
                  onChanged: (year) {
                    if (year == null) return;
                    final candidates = monthPeriods
                        .where((period) => period.reportYear == year)
                        .toList();
                    if (candidates.isEmpty) return;
                    onChanged(candidates.last.id);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: const InputDecoration(labelText: 'Bulan'),
                  items: [
                    for (final period in periodsInYear)
                      DropdownMenuItem<int>(
                        value: period.periodStart?.month ??
                            _monthFromLabel(period.periodLabel) ??
                            1,
                        child: Text(
                          _monthName(
                            period.periodStart?.month ??
                                _monthFromLabel(period.periodLabel) ??
                                1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (month) {
                    if (month == null) return;
                    for (final period in periodsInYear) {
                      final candidate = period.periodStart?.month ??
                          _monthFromLabel(period.periodLabel);
                      if (candidate == month) {
                        onChanged(period.id);
                        return;
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _monthName(int month) {
    if (month < 1 || month > 12) return '—';
    return _months[month - 1];
  }

  static int? _monthFromLabel(String label) {
    final normalized = label.toLowerCase();
    for (var i = 0; i < _months.length; i++) {
      if (normalized.contains(_months[i].toLowerCase())) return i + 1;
    }
    return null;
  }
}



class CompactMonthlyPeriodSelector extends StatelessWidget {
  const CompactMonthlyPeriodSelector({
    required this.periods,
    required this.selectedPeriodId,
    required this.onChanged,
    super.key,
  });

  final List<ReportPeriod> periods;
  final String selectedPeriodId;
  final ValueChanged<String> onChanged;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final available = periods
        .where(
          (period) =>
              period.periodType == 'MONTH' &&
              period.reportYear != null &&
              period.periodStart != null,
        )
        .toList()
      ..sort((a, b) => b.periodStart!.compareTo(a.periodStart!));

    if (available.isEmpty) return const SizedBox.shrink();

    final current = available.firstWhere(
      (period) => period.id == selectedPeriodId,
      orElse: () => available.first,
    );

    return PopupMenuButton<String>(
      initialValue: current.id,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final period in available)
          PopupMenuItem<String>(
            value: period.id,
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18),
                const SizedBox(width: 8),
                Text(_label(period)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              _label(current),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  static String _label(ReportPeriod period) {
    final start = period.periodStart;
    if (start == null) return period.periodLabel;

    final month = _months[start.month - 1];
    return '\$month \${start.year}';
  }
}
