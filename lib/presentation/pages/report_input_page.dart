import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../application/providers/commander_providers.dart';
import '../../application/providers/dashboard_providers.dart';
import '../../application/providers/report_input_providers.dart';
import '../../application/providers/reporting_providers.dart';
import '../../application/providers/gakkum_providers.dart';
import '../../application/providers/violation_providers.dart';
import '../../application/providers/criminal_offense_providers.dart';
import '../../application/providers/laka_providers.dart';
import '../../application/providers/provos_providers.dart';
import '../../application/providers/sim_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_access_context_entities.dart';
import '../../domain/entities/reference_entities.dart';
import '../../domain/entities/report_input_entities.dart';

class ReportInputPage extends ConsumerStatefulWidget {
  const ReportInputPage({super.key});

  @override
  ConsumerState<ReportInputPage> createState() => _ReportInputPageState();
}

class _ReportInputPageState extends ConsumerState<ReportInputPage> {
  static const _domains = <String, String>{
    'GAKKUM': 'Statistik Giat Gakkum',
    'PELANGGARAN': 'Statistik Pelanggaran',
    'SIM_TNI': 'Rekapitulasi SIM TNI',
    'PROVOS': 'Rekapitulasi Provos TNI AD',
    'LAKA_LALIN': 'Statistik Laka Lalin',
    'TINDAK_PIDANA': 'Rekap Tindak Pidana',
  };

  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _valueControllers = {};

  String _domainCode = 'GAKKUM';
  String? _pomdamId;
  String? _selectedPeriodId;
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  bool _saving = false;
  String _tindakSearch = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _valueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<ReportPeriod> _monthlyPeriods(ReportInputCatalog catalog) {
    final periods = [
      for (final period in catalog.periods)
        if (period.periodType == 'MONTH' &&
            period.periodStart != null &&
            period.periodEnd != null)
          period,
    ];
    periods.sort((a, b) => b.periodStart!.compareTo(a.periodStart!));
    return periods;
  }

  ReportPeriod? _findPeriodById(
    List<ReportPeriod> periods,
    String? id,
  ) {
    if (id == null) return null;
    for (final period in periods) {
      if (period.id == id) return period;
    }
    return null;
  }

  ReportPeriod? _findPeriodForMonth(
    List<ReportPeriod> periods,
    DateTime month,
  ) {
    for (final period in periods) {
      final start = period.periodStart;
      if (start != null &&
          start.year == month.year &&
          start.month == month.month) {
        return period;
      }
    }
    return null;
  }

  String _monthLabel(DateTime month) {
    const months = [
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
    return '${months[month.month - 1]} ${month.year}';
  }

  TextEditingController _controller(String key) {
    return _valueControllers.putIfAbsent(key, TextEditingController.new);
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(commanderAccessContextProvider).value;

    if (access == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!access.hasCapability(CommanderCapabilities.manageReportData)) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Akun ini tidak memiliki akses untuk menginput laporan.',
          ),
        ),
      );
    }

    final catalogState = ref.watch(reportInputCatalogProvider);

    return catalogState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (catalog) {
        final monthlyPeriods = _monthlyPeriods(catalog);
        final selectedPeriod =
            _findPeriodById(monthlyPeriods, _selectedPeriodId) ??
            _findPeriodForMonth(monthlyPeriods, _selectedMonth);

        if (_selectedPeriodId != selectedPeriod?.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedPeriodId != selectedPeriod?.id) {
              setState(() {
                _selectedPeriodId = selectedPeriod?.id;
                if (selectedPeriod?.periodStart != null) {
                  final start = selectedPeriod!.periodStart!;
                  _selectedMonth = DateTime(start.year, start.month);
                }
              });
            }
          });
        }

        final availablePomdams = [
          for (final pomdam in catalog.pomdams)
            if (access.canReadPomdam(pomdam.id)) pomdam,
        ];

        final effectivePomdamId = _pomdamId != null &&
                availablePomdams.any((pomdam) => pomdam.id == _pomdamId)
            ? _pomdamId
            : (access.isPomdamScoped && availablePomdams.length == 1
                ? availablePomdams.first.id
                : null);

        if (_pomdamId != effectivePomdamId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pomdamId != effectivePomdamId) {
              setState(() => _pomdamId = effectivePomdamId);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Input Laporan'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(access: access),
                const SizedBox(height: 14),
                _SubmissionMetaCard(
                  domainCode: _domainCode,
                  domains: _domains,
                  periods: monthlyPeriods,
                  selectedPeriod: selectedPeriod,
                  selectedMonth: _selectedMonth,
                  pomdams: availablePomdams,
                  pomdamId: effectivePomdamId,
                  onDomainChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _domainCode = value;
                      _tindakSearch = '';
                    });
                  },
                  onPomdamChanged: (value) {
                    setState(() => _pomdamId = value);
                  },
                  onPeriodChanged: (value) {
                    final period = _findPeriodById(monthlyPeriods, value);
                    setState(() {
                      _selectedPeriodId = period?.id;
                      if (period?.periodStart != null) {
                        final start = period!.periodStart!;
                        _selectedMonth = DateTime(start.year, start.month);
                      }
                    });
                  },
                  onPickMonth: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000, 1, 1),
                      lastDate: DateTime(2100, 12, 31),
                      initialDate: _selectedMonth,
                      helpText: 'Pilih bulan laporan',
                    );
                    if (value == null || !mounted) return;
                    final month = DateTime(value.year, value.month);
                    final existing =
                        _findPeriodForMonth(monthlyPeriods, month);
                    setState(() {
                      _selectedMonth = month;
                      _selectedPeriodId = existing?.id;
                    });
                  },
                ),
                const SizedBox(height: 14),
                const _InputRuleCard(),
                const SizedBox(height: 14),
                _buildDomainForm(catalog),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan umum (opsional)',
                    hintText: 'Tambahkan catatan untuk submission ini.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _submit(catalog, effectivePomdamId, selectedPeriod),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      _saving ? 'Menyimpan…' : 'Simpan & Kirim Laporan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDomainForm(ReportInputCatalog catalog) {
    return switch (_domainCode) {
      'GAKKUM' => _buildGakkum(catalog),
      'PELANGGARAN' => _buildViolations(catalog),
      'SIM_TNI' => _buildSim(catalog),
      'PROVOS' => _buildProvos(catalog),
      'LAKA_LALIN' => _buildLaka(catalog),
      'TINDAK_PIDANA' => _buildTindakPidana(catalog),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildGakkum(ReportInputCatalog catalog) {
    return _SectionCard(
      title: 'GAKKUM',
      subtitle: '14 kegiatan leaf. Parent tidak dimasukkan agar tidak double count.',
      child: Column(
        children: [
          for (final option in catalog.gakkum)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('gakkum:${option.versionId}'),
            ),
        ],
      ),
    );
  }

  Widget _buildViolations(ReportInputCatalog catalog) {
    return _SectionCard(
      title: 'PELANGGARAN',
      subtitle: 'Isi angka per jenis pelanggaran dan golongan personel.',
      child: Column(
        children: [
          for (final option in catalog.violations)
            _MatrixCard(
              title: option.name,
              subtitle: '${option.category} · ${option.code}',
              columns: catalog.personnelCategories,
              controllers: {
                for (final pc in catalog.personnelCategories)
                  pc.id: _controller(
                    'pelanggaran:${option.versionId}:${pc.id}',
                  ),
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSim(ReportInputCatalog catalog) {
    return _SectionCard(
      title: 'SIM TNI',
      subtitle: 'Kosong = NOT_REPORTED. Angka 0 = VALID dengan nilai nol.',
      child: Column(
        children: [
          for (final option in catalog.simTypes)
            _NumberRow(
              label: option.displayName,
              code: option.code,
              controller: _controller('sim:${option.id}'),
            ),
        ],
      ),
    );
  }

  Widget _buildProvos(ReportInputCatalog catalog) {
    return _SectionCard(
      title: 'PROVOS',
      subtitle: 'Tiga bagian disimpan terpisah: kekuatan, pendidikan, personel.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubsectionTitle('Kekuatan'),
          for (final option in catalog.provosStrengthMeasures)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('provos:strength:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Pendidikan'),
          for (final option in catalog.educationStatuses)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('provos:education:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Personel'),
          for (final option in catalog.personnelCategories)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('provos:personnel:${option.id}'),
            ),
        ],
      ),
    );
  }

  Widget _buildLaka(ReportInputCatalog catalog) {
    return _SectionCard(
      title: 'LAKA LALIN',
      subtitle: 'Kejadian, korban, pangkat, personel, dan material adalah bagian terpisah.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubsectionTitle('Kejadian'),
          for (final option in catalog.accidentTypes)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('laka:accident:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Korban'),
          for (final option in catalog.victimOutcomes)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('laka:victim:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Pangkat korban'),
          for (final option in catalog.personnelCategories)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('laka:rank:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Personel'),
          for (final option in catalog.personnelCategories)
            _NumberRow(
              label: option.name,
              code: option.code,
              controller: _controller('laka:personnel:${option.id}'),
            ),
          const SizedBox(height: 8),
          _SubsectionTitle('Material'),
          for (final vehicle in catalog.vehicleCategories)
            for (final damage in catalog.materialDamageTypes)
              _NumberRow(
                label: '${vehicle.name} · ${damage.name}',
                code: vehicle.code + ' / ' + damage.code,
                controller: _controller(
                  'laka:material:${vehicle.id}:${damage.id}',
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTindakPidana(ReportInputCatalog catalog) {
    final query = _tindakSearch.trim().toLowerCase();
    final options = query.isEmpty
        ? catalog.criminalOffenses
        : [
            for (final option in catalog.criminalOffenses)
              if (option.name.toLowerCase().contains(query) ||
                  option.sourceNumber.toString().contains(query))
                option,
          ];

    return _SectionCard(
      title: 'TINDAK PIDANA',
      subtitle: '105 jenis pidana × 4 golongan personel. Gunakan pencarian agar cepat.',
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _tindakSearch = value),
            decoration: const InputDecoration(
              labelText: 'Cari nomor atau nama tindak pidana',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Menampilkan ${options.length} dari ${catalog.criminalOffenses.length} jenis.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final option in options)
            _MatrixCard(
              title: '${option.sourceNumber}. ${option.name}',
              subtitle: 'Tindak pidana',
              columns: catalog.personnelCategories,
              controllers: {
                for (final pc in catalog.personnelCategories)
                  pc.id: _controller(
                    'pidana:${option.versionId}:${pc.id}',
                  ),
              },
            ),
        ],
      ),
    );
  }

  Future<void> _submit(
    ReportInputCatalog catalog,
    String? pomdamId,
    ReportPeriod? selectedPeriod,
  ) async {
    if (pomdamId == null || pomdamId.isEmpty) {
      _showMessage('Pilih POMDAM terlebih dahulu.');
      return;
    }

    Map<String, dynamic> payload;
    try {
      payload = _buildPayload(catalog);
    } on FormatException catch (error) {
      _showMessage(error.message);
      return;
    }

    setState(() => _saving = true);
    try {
      final repository = ref.read(reportInputRepositoryProvider);
      final period = selectedPeriod ??
          await repository.getOrCreateMonthlyPeriod(
            year: _selectedMonth.year,
            month: _selectedMonth.month,
          );

      await repository.submitReport(
        reportType: _domainCode,
        periodId: period.id,
        pomdamId: pomdamId,
        payload: payload,
      );

      _clearInputFields();
      ref.invalidate(reportInputCatalogProvider);
      ref.invalidate(reportAuditSummaryProvider);
      ref.invalidate(reportProvenanceProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(commanderDashboardProvider);
      ref.invalidate(gakkumDashboardProvider);
      ref.invalidate(gakkumPeriodsProvider);
      ref.invalidate(violationDashboardProvider);
      ref.invalidate(violationPeriodsProvider);
      ref.invalidate(simDashboardProvider);
      ref.invalidate(simPeriodsProvider);
      ref.invalidate(provosDashboardProvider);
      ref.invalidate(provosPeriodsProvider);
      ref.invalidate(lakaDashboardProvider);
      ref.invalidate(lakaPeriodsProvider);
      ref.invalidate(criminalOffenseDashboardProvider);
      ref.invalidate(criminalOffensePeriodsProvider);

      if (!mounted) return;
      _showMessage(
        'Laporan ${_domains[_domainCode] ?? _domainCode} berhasil disimpan untuk '
        '${period.periodLabel}.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _clearInputFields() {
    for (final controller in _valueControllers.values) {
      controller.clear();
    }
    _notesController.clear();
    _tindakSearch = '';
  }

  String _friendlyError(Object error) {
    final message = error is AppException ? error.message : error.toString();
    const known = <String, String>{
      'PERIOD_LOCKED_IMPORTED':
          'Periode/POMDAM ini berasal dari impor Excel dan dikunci. '
          'Pilih bulan yang belum diimpor untuk input aplikasi.',
      'INCOMPLETE_GAKKUM_PAYLOAD':
          'Struktur GAKKUM berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_PELANGGARAN_PAYLOAD':
          'Struktur Pelanggaran berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_SIM_PAYLOAD':
          'Struktur SIM TNI berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_PROVOS_STRENGTH_PAYLOAD':
          'Struktur Kekuatan Provos berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_PROVOS_EDUCATION_PAYLOAD':
          'Struktur Pendidikan Provos berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_PROVOS_PERSONNEL_PAYLOAD':
          'Struktur Personel Provos berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_LAKA_ACCIDENT_PAYLOAD':
          'Struktur Kejadian Laka berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_LAKA_VICTIM_OUTCOME_PAYLOAD':
          'Struktur Korban Laka berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_LAKA_VICTIM_RANK_PAYLOAD':
          'Struktur Pangkat Korban Laka berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_LAKA_PERSONNEL_PAYLOAD':
          'Struktur Personel Laka berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_LAKA_MATERIAL_PAYLOAD':
          'Struktur Material Laka berubah. Muat ulang form sebelum mengirim.',
      'INCOMPLETE_TINDAK_PIDANA_PAYLOAD':
          'Struktur Tindak Pidana berubah. Muat ulang form sebelum mengirim.',
      'VALID_VALUE_REQUIRED':
          'Setiap nilai yang diisi harus berupa bilangan bulat non-negatif.',
      'INVALID_NON_NEGATIVE_INTEGER':
          'Nilai harus berupa bilangan bulat non-negatif.',
      'INTEGER_OUT_OF_RANGE':
          'Nilai terlalu besar untuk disimpan di database.',
      'INVALID_INPUT_STATUS':
          'Status input tidak valid.',
    };

    for (final entry in known.entries) {
      if (message.contains(entry.key)) return entry.value;
    }
    return message;
  }
  Map<String, dynamic> _buildPayload(ReportInputCatalog catalog) {
    final notes = _notesController.text.trim();
    switch (_domainCode) {
      case 'GAKKUM':
        return {
          'entries': [
            for (final option in catalog.gakkum)
              _entry(
                'activity_version_id',
                option.versionId,
                _controller('gakkum:${option.versionId}').text,
                notes,
              ),
          ],
        };
      case 'PELANGGARAN':
        return {
          'entries': [
            for (final option in catalog.violations)
              for (final pc in catalog.personnelCategories)
                _entryMulti(
                  {'violation_version_id': option.versionId, 'personnel_category_id': pc.id},
                  _controller('pelanggaran:${option.versionId}:${pc.id}').text,
                  notes,
                ),
          ],
        };
      case 'SIM_TNI':
        return {
          'entries': [
            for (final option in catalog.simTypes)
              _entry(
                'sim_type_id',
                option.id,
                _controller('sim:${option.id}').text,
                notes,
              ),
          ],
        };
      case 'PROVOS':
        return {
          'strength': [
            for (final option in catalog.provosStrengthMeasures)
              _entry(
                'strength_measure_id',
                option.id,
                _controller('provos:strength:${option.id}').text,
                notes,
              ),
          ],
          'education': [
            for (final option in catalog.educationStatuses)
              _entry(
                'education_status_id',
                option.id,
                _controller('provos:education:${option.id}').text,
                notes,
              ),
          ],
          'personnel': [
            for (final option in catalog.personnelCategories)
              _entry(
                'personnel_category_id',
                option.id,
                _controller('provos:personnel:${option.id}').text,
                notes,
              ),
          ],
        };
      case 'LAKA_LALIN':
        return {
          'accidents': [
            for (final option in catalog.accidentTypes)
              _entry(
                'accident_type_id',
                option.id,
                _controller('laka:accident:${option.id}').text,
                notes,
              ),
          ],
          'victim_outcomes': [
            for (final option in catalog.victimOutcomes)
              _entry(
                'victim_outcome_id',
                option.id,
                _controller('laka:victim:${option.id}').text,
                notes,
              ),
          ],
          'victim_ranks': [
            for (final option in catalog.personnelCategories)
              _entry(
                'personnel_category_id',
                option.id,
                _controller('laka:rank:${option.id}').text,
                notes,
              ),
          ],
          'personnel': [
            for (final option in catalog.personnelCategories)
              _entry(
                'personnel_category_id',
                option.id,
                _controller('laka:personnel:${option.id}').text,
                notes,
              ),
          ],
          'materials': [
            for (final vehicle in catalog.vehicleCategories)
              for (final damage in catalog.materialDamageTypes)
                _entryMulti(
                  {
                    'vehicle_category_id': vehicle.id,
                    'material_damage_type_id': damage.id,
                  },
                  _controller('laka:material:${vehicle.id}:${damage.id}').text,
                  notes,
                ),
          ],
        };
      case 'TINDAK_PIDANA':
        return {
          'entries': [
            for (final option in catalog.criminalOffenses)
              for (final pc in catalog.personnelCategories)
                _entryMulti(
                  {
                    'criminal_offense_version_id': option.versionId,
                    'personnel_category_id': pc.id,
                  },
                  _controller('pidana:${option.versionId}:${pc.id}').text,
                  notes,
                ),
          ],
        };
    }
    return <String, dynamic>{};
  }

  int? _parseInputValue(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final value = int.tryParse(trimmed);
    if (value == null || value < 0) {
      throw const FormatException(
        'Nilai harus berupa bilangan bulat non-negatif.',
      );
    }
    return value;
  }

  Map<String, dynamic> _entry(
    String idField,
    String id,
    String text,
    String notes,
  ) {
    final value = _parseInputValue(text);
    return {
      idField: id,
      'value': value,
      'data_status': value == null ? 'NOT_REPORTED' : 'VALID',
      'notes': notes.isEmpty ? null : notes,
    };
  }

  Map<String, dynamic> _entryMulti(
    Map<String, String> ids,
    String text,
    String notes,
  ) {
    final value = _parseInputValue(text);
    return {
      ...ids,
      'value': value,
      'data_status': value == null ? 'NOT_REPORTED' : 'VALID',
      'notes': notes.isEmpty ? null : notes,
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.access});

  final CommanderAccessContext access;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.storage_outlined, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATABASE-NATIVE REPORT ENTRY',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Laporan baru masuk langsung ke Supabase. Excel tidak diperlukan untuk submission baru.',
                  ),
                ],
              ),
            ),
            Chip(label: Text(access.role!.displayName)),
          ],
        ),
      ),
    );
  }
}

class _SubmissionMetaCard extends StatelessWidget {
  const _SubmissionMetaCard({
    required this.domainCode,
    required this.domains,
    required this.periods,
    required this.selectedPeriod,
    required this.selectedMonth,
    required this.pomdams,
    required this.pomdamId,
    required this.onDomainChanged,
    required this.onPomdamChanged,
    required this.onPeriodChanged,
    required this.onPickMonth,
  });

  final String domainCode;
  final Map<String, String> domains;
  final List<ReportPeriod> periods;
  final ReportPeriod? selectedPeriod;
  final DateTime selectedMonth;
  final List<Pomdam> pomdams;
  final String? pomdamId;
  final ValueChanged<String?> onDomainChanged;
  final ValueChanged<String?> onPomdamChanged;
  final ValueChanged<String?> onPeriodChanged;
  final VoidCallback onPickMonth;

  String _monthLabel(DateTime month) {
    const months = [
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
    return '${months[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 330,
                  child: DropdownButtonFormField<String>(
                    initialValue: domainCode,
                    decoration: const InputDecoration(
                      labelText: 'Jenis laporan',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final entry in domains.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                    ],
                    onChanged: onDomainChanged,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    initialValue: pomdamId,
                    decoration: const InputDecoration(
                      labelText: 'POMDAM',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final pomdam in pomdams)
                        DropdownMenuItem(
                          value: pomdam.id,
                          child: Text('${pomdam.code} · ${pomdam.shortName}'),
                        ),
                    ],
                    onChanged: onPomdamChanged,
                  ),
                ),
                SizedBox(
                  width: 330,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedPeriod?.id,
                    decoration: const InputDecoration(
                      labelText: 'Periode yang sudah tersedia',
                      hintText: 'Pilih periode resmi atau gunakan bulan di samping',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final period in periods)
                        DropdownMenuItem<String>(
                          value: period.id,
                          child: Text(period.periodLabel),
                        ),
                    ],
                    onChanged: onPeriodChanged,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onPickMonth,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('Bulan · ${_monthLabel(selectedMonth)}'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selectedPeriod == null
                      ? Icons.add_circle_outline
                      : Icons.check_circle_outline,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedPeriod == null
                        ? 'Periode ${_monthLabel(selectedMonth)} belum ada. '
                          'Periode resmi akan dibuat otomatis saat laporan disimpan.'
                        : 'Periode ${selectedPeriod!.periodLabel} sudah ada di database. '
                          'Bila POMDAM ini berasal dari impor Excel, overwrite akan ditolak.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRuleCard extends StatelessWidget {
  const _InputRuleCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Aturan penting: kosong = NOT_REPORTED; isi 0 = VALID bernilai nol. '
                'Operator tidak dapat memasukkan source_cell, INVALID_SOURCE, atau ESTIMATED.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  const _SubsectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.code,
    required this.controller,
  });

  final String label;
  final String code;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(code, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: const [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                labelText: 'Nilai',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixCard extends StatelessWidget {
  const _MatrixCard({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.controllers,
  });

  final String title;
  final String subtitle;
  final List<PersonnelCategory> columns;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final column in columns)
                  SizedBox(
                    width: 125,
                    child: TextField(
                      controller: controllers[column.id],
                      keyboardType: TextInputType.number,
                      inputFormatters: const [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        labelText: column.code,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
