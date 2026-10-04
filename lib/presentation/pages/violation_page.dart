import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reference_data_providers.dart';
import '../../application/providers/violation_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/violation_entities.dart';
import '../widgets/analytics_ui.dart';
import '../widgets/report_filters.dart';
import '../widgets/visual_analytics.dart';

class ViolationPage extends ConsumerStatefulWidget {
  const ViolationPage({super.key});

  @override
  ConsumerState<ViolationPage> createState() => _ViolationPageState();
}

class _ViolationPageState extends ConsumerState<ViolationPage> {
  String? _selectedPeriodId;
  String? _selectedPomdamId;
  String? _selectedPersonnelCategoryId;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(violationPeriodsProvider);
    final pomdamsState = ref.watch(pomdamsProvider);
    final personnelState = ref.watch(personnelCategoriesProvider);
    final categoriesState = ref.watch(violationCategoriesProvider);

    return periodsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          _MessageState(message: _errorMessage(error)),
      data: (periods) {
        if (periods.isEmpty) {
          return const _MessageState(
            message: 'Belum ada periode dengan data Pelanggaran.',
          );
        }

        final selectedPeriod = periods.firstWhere(
          (period) => period.id == _selectedPeriodId,
          orElse: () => periods.first,
        );

        final query = ViolationDashboardQuery(
          periodId: selectedPeriod.id,
          pomdamId: _selectedPomdamId,
          personnelCategoryId: _selectedPersonnelCategoryId,
          category: _selectedCategory,
        );

        final dashboard = ref.watch(violationDashboardProvider(query));

        return VisualReportFrame(
          title: 'Pelanggaran',
          contentKey: selectedPeriod.id,
          accent: AppVisualPalettes.pelanggaran.primary,
          periodControl: CompactMonthlyPeriodSelector(
            periods: periods,
            selectedPeriodId: selectedPeriod.id,
            onChanged: (value) => setState(() => _selectedPeriodId = value),
          ),
          filters: [
            _PomdamFilter(
              state: pomdamsState,
              selectedValue: _selectedPomdamId,
              onChanged: (value) =>
                  setState(() => _selectedPomdamId = value),
            ),
            _PersonnelFilter(
              state: personnelState,
              selectedValue: _selectedPersonnelCategoryId,
              onChanged: (value) =>
                  setState(() => _selectedPersonnelCategoryId = value),
            ),
            _CategoryFilter(
              state: categoriesState,
              selectedValue: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          ],
          child: dashboard.when(
            loading: () => const _LoadingVisual(),
            error: (error, stackTrace) =>
                _MessageState(message: _errorMessage(error)),
            data: (snapshot) => _DashboardVisual(snapshot: snapshot),
          ),
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Data Pelanggaran belum dapat dibaca.';
  }
}

class _DashboardVisual extends StatelessWidget {
  const _DashboardVisual({required this.snapshot});

  final ViolationDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = AppVisualPalettes.pelanggaran;
    final ordered = [...snapshot.metrics]
      ..sort((a, b) => b.validTotal.compareTo(a.validTotal));

    final totalReports = snapshot.validCount +
        snapshot.notReportedCount +
        snapshot.estimatedCount +
        snapshot.invalidSourceCount +
        snapshot.missingValueCount;
    final validPercent =
        totalReports == 0 ? 0.0 : (snapshot.validCount / totalReports * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: AnimatedMetric(
                  value: snapshot.validTotal,
                  label: 'TOTAL',
                  color: palette.primary,
                ),
              ),
              Expanded(
                child: AnimatedMetric(
                  value: validPercent,
                  suffix: '%',
                  label: 'VALID',
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        VisualPanel(
          title: 'Peringkat Pelanggaran',
          accent: palette.primary,
          child: AnimatedRankBarChart(
            items: [
              for (final metric in ordered)
                VisualDatum(
                  label: metric.canonicalName,
                  value: metric.validTotal.toDouble(),
                ),
            ],
            palette: palette,
            maxItems: 8,
            height: 320,
          ),
        ),
        const SizedBox(height: 24),
        VisualPanel(
          title: 'Kualitas Data',
          accent: palette.primary,
          child: AnimatedStatusRing(
            valid: snapshot.validCount,
            attention: snapshot.notReportedCount + snapshot.estimatedCount,
            error: snapshot.invalidSourceCount + snapshot.missingValueCount,
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _PomdamFilter extends StatelessWidget {
  const _PomdamFilter({
    required this.state,
    required this.selectedValue,
    required this.onChanged,
  });

  final AsyncValue<List<Pomdam>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => state.when(
        loading: () => const SizedBox(
          width: 210,
          child: LinearProgressIndicator(),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (pomdams) => SizedBox(
          width: 210,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedValue,
            decoration:
                const InputDecoration(labelText: 'POMDAM', isDense: true),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua POMDAM'),
              ),
              for (final pomdam in pomdams)
                DropdownMenuItem<String?>(
                  value: pomdam.id,
                  child: Text('${pomdam.code} · ${pomdam.shortName}'),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class _PersonnelFilter extends StatelessWidget {
  const _PersonnelFilter({
    required this.state,
    required this.selectedValue,
    required this.onChanged,
  });

  final AsyncValue<List<PersonnelCategory>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => state.when(
        loading: () => const SizedBox(
          width: 210,
          child: LinearProgressIndicator(),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (categories) => SizedBox(
          width: 210,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedValue,
            decoration:
                const InputDecoration(labelText: 'Personel', isDense: true),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua Personel'),
              ),
              for (final category in categories)
                DropdownMenuItem<String?>(
                  value: category.id,
                  child: Text('${category.code} · ${category.name}'),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.state,
    required this.selectedValue,
    required this.onChanged,
  });

  final AsyncValue<List<String>> state;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => state.when(
        loading: () => const SizedBox(
          width: 210,
          child: LinearProgressIndicator(),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (categories) => DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(
            labelText: 'Kategori',
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua kategori'),
            ),
            for (final category in categories)
              DropdownMenuItem<String?>(
                value: category,
                child: Text(category),
              ),
          ],
          onChanged: onChanged,
        ),
      );
}

class _LoadingVisual extends StatelessWidget {
  const _LoadingVisual();

  @override
  Widget build(BuildContext context) {
    return const VisualPanel(
      child: SizedBox(
        height: 270,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}
