import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/commander_access_context_providers.dart';
import '../../application/providers/commander_drilldown_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/commander_drilldown_entities.dart';

class CommanderDrilldownPage extends ConsumerStatefulWidget {
  const CommanderDrilldownPage({
    required this.domainCode,
    required this.pomdamId,
    required this.dimensionCode,
    required this.recordId,
    super.key,
  });

  final String domainCode;
  final String? pomdamId;
  final String? dimensionCode;
  final String? recordId;

  @override
  ConsumerState<CommanderDrilldownPage> createState() =>
      _CommanderDrilldownPageState();
}

class _CommanderDrilldownPageState
    extends ConsumerState<CommanderDrilldownPage> {
  String? _dimensionCode;
  String? _recordId;

  @override
  void initState() {
    super.initState();
    _dimensionCode = widget.dimensionCode;
    _recordId = widget.recordId;
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(commanderAccessContextProvider).value;

    if (access == null) {
      return const _LoadingView();
    }

    if (!access.canUseCommanderDashboard) {
      return const _MessageView(
        title: 'Drill-down tidak tersedia',
        message: 'Akun ini tidak memiliki akses Commander Drill-down.',
      );
    }

    final effectivePomdamId = access.isPomdamScoped
        ? (access.pomdamIds.length == 1 ? access.pomdamIds.first : null)
        : widget.pomdamId;

    if (access.isPomdamScoped && effectivePomdamId == null) {
      return const _MessageView(
        title: 'Scope belum lengkap',
        message:
            'Commander Drill-down membutuhkan tepat satu POMDAM pada scope akun.',
      );
    }

    if (effectivePomdamId != null &&
        !access.canReadPomdam(effectivePomdamId)) {
      return const _MessageView(
        title: 'Scope tidak sah',
        message: 'POMDAM yang diminta berada di luar authorization scope.',
      );
    }

    final query = CommanderDrilldownQuery(
      domainCode: widget.domainCode,
      pomdamId: effectivePomdamId,
      dimensionCode: _dimensionCode,
    );
    final state = ref.watch(commanderDrilldownProvider(query));

    return state.when(
      loading: () => const _LoadingView(),
      error: (error, stack) => _ErrorView(
        error: error,
        retry: () => ref.invalidate(commanderDrilldownProvider(query)),
      ),
      data: (snapshot) => _Content(
        snapshot: snapshot,
        selectedDimensionCode: _dimensionCode,
        selectedRecordId: _recordId,
        onDimensionSelected: (code) {
          setState(() {
            _dimensionCode = code;
            _recordId = null;
          });
        },
        onRecordSelected: (recordId) {
          setState(() => _recordId = recordId);
        },
        onBack: () => context.pop(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.snapshot,
    required this.selectedDimensionCode,
    required this.selectedRecordId,
    required this.onDimensionSelected,
    required this.onRecordSelected,
    required this.onBack,
  });

  final CommanderDrilldownSnapshot snapshot;
  final String? selectedDimensionCode;
  final String? selectedRecordId;
  final ValueChanged<String?> onDimensionSelected;
  final ValueChanged<String> onRecordSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 700 ? 14.0 : 24.0;
    final selectedDimension = _findDimension(
      snapshot.dimensions,
      selectedDimensionCode,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 30),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Kembali',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.domainName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        snapshot.asOf == null
                            ? 'Periode tidak tersedia'
                            : 'AS-OF · ' + snapshot.asOf!.label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: snapshot.scope.isAllPomdam
                      ? 'SEMUA POMDAM'
                      : (snapshot.scope.pomdamShortName ?? 'POMDAM'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PathCard(
          selectedDimension: selectedDimension,
          selectedRecordId: selectedRecordId,
        ),
        if (selectedRecordId != null) ...[
          const SizedBox(height: 12),
          _ProvenanceSection(
            domainCode: snapshot.domainCode,
            recordId: selectedRecordId!,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'DIMENSIONS',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 8),
        if (snapshot.dimensions.isEmpty)
          const _EmptyCard(message: 'Tidak ada dimensi pada periode ini.')
        else
          for (final dimension in snapshot.dimensions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DimensionTile(
                dimension: dimension,
                selected: dimension.code == selectedDimensionCode,
                onTap: () {
                  onDimensionSelected(
                    dimension.code == selectedDimensionCode
                        ? null
                        : dimension.code,
                  );
                },
              ),
            ),
        const SizedBox(height: 8),
        Text(
          selectedDimension == null
              ? 'FACT RECORDS'
              : 'FACT RECORDS · ' + selectedDimension.name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 8),
        if (snapshot.records.isEmpty)
          const _EmptyCard(
            message: 'Tidak ada fact record pada seleksi ini.',
          )
        else
          for (final record in snapshot.records)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RecordTile(
                record: record,
                selected: record.recordId == selectedRecordId,
                onTap: () => onRecordSelected(record.recordId),
              ),
            ),
      ],
    );
  }

  CommanderDrilldownDimension? _findDimension(
    List<CommanderDrilldownDimension> dimensions,
    String? code,
  ) {
    if (code == null) return null;
    for (final dimension in dimensions) {
      if (dimension.code == code) return dimension;
    }
    return null;
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.selectedDimension,
    required this.selectedRecordId,
  });

  final CommanderDrilldownDimension? selectedDimension;
  final String? selectedRecordId;

  @override
  Widget build(BuildContext context) {
    final steps = <String>[
      'COMMANDER',
      if (selectedDimension != null) selectedDimension!.group,
      if (selectedDimension != null) 'DIMENSION',
      if (selectedRecordId != null) 'FACT',
      if (selectedRecordId != null) 'SOURCE',
    ];

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 7,
          runSpacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const Icon(Icons.chevron_right, size: 18),
              _StatusBadge(label: steps[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _DimensionTile extends StatelessWidget {
  const _DimensionTile({
    required this.dimension,
    required this.selected,
    required this.onTap,
  });

  final CommanderDrilldownDimension dimension;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final issueCount = dimension.invalidSourceRows +
        dimension.notReportedRows +
        dimension.estimatedRows;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dimension.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dimension.group + ' · ' + dimension.code,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dimension.validRows.toString() +
                          ' valid dari ' +
                          dimension.factRows.toString() +
                          ' fact row',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Text(
                _format(dimension.validTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 9),
              _StatusBadge(
                label: issueCount == 0 ? 'VALID' : issueCount.toString() + ' ISSUE',
              ),
              const SizedBox(width: 4),
              Icon(
                selected ? Icons.expand_less : Icons.chevron_right,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final CommanderDrilldownRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.dimensionName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.pomdamCode +
                          ' · ' +
                          record.pomdamShortName +
                          (record.secondaryName == null
                              ? ''
                              : ' · ' + record.secondaryName!),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          record.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Text(
                _format(record.value),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: record.dataStatus.name.toUpperCase(),
              ),
              if (record.hasSource) ...[
                const SizedBox(width: 5),
                Icon(
                  selected ? Icons.link : Icons.link_outlined,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProvenanceSection extends ConsumerWidget {
  const _ProvenanceSection({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      commanderFactProvenanceProvider(
        CommanderFactProvenanceQuery(
          domainCode: domainCode,
          recordId: recordId,
        ),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: state.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stack) => _InlineError(error: error),
          data: (trace) => _TraceView(trace: trace),
        ),
      ),
    );
  }
}

class _TraceView extends ConsumerStatefulWidget {
  const _TraceView({required this.trace});

  final CommanderFactProvenance trace;

  @override
  ConsumerState<_TraceView> createState() => _TraceViewState();
}

class _TraceViewState extends ConsumerState<_TraceView> {
  bool _showSheetContext = false;

  @override
  Widget build(BuildContext context) {
    final trace = widget.trace;
    final source = trace.source;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOURCE / LINEAGE',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          trace.pomdamCode + ' · ' + trace.pomdamShortName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(trace.period.label),
        const SizedBox(height: 12),
        if (!source.found)
          const _EmptyCard(
            message: 'Fact ini belum memiliki source cell.',
          )
        else ...[
          if (source.workbook != null) ...[
            _TraceField(
              label: 'WORKBOOK',
              value: source.workbook!.name,
            ),
            _TraceField(
              label: 'SHEET',
              value: source.workbook!.sheet +
                  (source.workbook!.sheetIndex == null
                      ? ''
                      : ' · index ' + source.workbook!.sheetIndex.toString()),
            ),
            _TraceField(
              label: 'IMPORT',
              value: source.workbook!.importStatus +
                  ' · ' +
                  source.workbook!.periodResolutionStatus,
            ),
          ],
          if (source.cell != null) ...[
            _TraceField(
              label: 'CELL',
              value: source.cell!.ref +
                  (source.cell!.rowLabel == null
                      ? ''
                      : ' · ' + source.cell!.rowLabel!),
            ),
            _TraceField(
              label: 'COLUMN',
              value: source.cell!.columnLabel ?? source.cell!.columnLetter,
            ),
            _TraceField(
              label: 'RAW VALUE',
              value: source.cell!.rawValue ?? '—',
            ),
            if (source.cell!.formulaText != null)
              _TraceField(
                label: 'FORMULA',
                value: source.cell!.formulaText!,
              ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showSheetContext = !_showSheetContext);
              },
              icon: Icon(
                _showSheetContext
                    ? Icons.visibility_off_outlined
                    : Icons.table_view_outlined,
              ),
              label: Text(
                _showSheetContext
                    ? 'Tutup source sheet'
                    : 'Buka source sheet',
              ),
            ),
            if (_showSheetContext) ...[
              const SizedBox(height: 12),
              _SourceSheetContextSection(
                domainCode: trace.domain,
                recordId: trace.recordId,
              ),
              const SizedBox(height: 12),
              _OriginalSourceFileSection(
                domainCode: trace.domain,
                recordId: trace.recordId,
              ),
            ],
          ],
        ],
      ],
    );
  }
}

class _OriginalSourceFileSection extends ConsumerStatefulWidget {
  const _OriginalSourceFileSection({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  ConsumerState<_OriginalSourceFileSection> createState() =>
      _OriginalSourceFileSectionState();
}

class _OriginalSourceFileSectionState
    extends ConsumerState<_OriginalSourceFileSection> {
  bool _checked = false;
  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'ORIGINAL XLSX SOURCE',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: !_checked ? _buildUnchecked(context) : _buildChecked(context),
        ),
      ),
    );
  }

  Widget _buildUnchecked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL XLSX SOURCE',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Periksa apakah file XLSX asli dari source report sudah tersimpan di Storage.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => setState(() => _checked = true),
          icon: const Icon(Icons.folder_open_outlined),
          label: const Text('Periksa file XLSX asli'),
        ),
      ],
    );
  }

  Widget _buildChecked(BuildContext context) {
    final state = ref.watch(
      commanderSourceFileContextProvider(
        CommanderSourceFileContextQuery(
          domainCode: widget.domainCode,
          recordId: widget.recordId,
        ),
      ),
    );

    return state.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORIGINAL XLSX SOURCE',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(),
        ],
      ),
      error: (error, stackTrace) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORIGINAL XLSX SOURCE',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error is AppException
                ? error.message
                : 'File XLSX asli belum dapat diperiksa.',
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.invalidate(
                commanderSourceFileContextProvider(
                  CommanderSourceFileContextQuery(
                    domainCode: widget.domainCode,
                    recordId: widget.recordId,
                  ),
                ),
              );
            },
            child: const Text('Coba lagi'),
          ),
        ],
      ),
      data: (fileContext) => _buildFileState(context, fileContext),
    );
  }

  Widget _buildFileState(
    BuildContext context,
    CommanderSourceFileContext fileContext,
  ) {
    final file = fileContext.file;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL XLSX SOURCE',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 7),
        if (fileContext.scopeRestricted) ...[
          const _StatusBadge(label: 'SCOPE RESTRICTED'),
          const SizedBox(height: 8),
          Text(
            'File workbook asli dibatasi untuk scope ini karena workbook bersama dapat memuat data Pomdam lain.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else if (!fileContext.found) ...[
          const _StatusBadge(label: 'FILE NOT AVAILABLE'),
          const SizedBox(height: 8),
          Text(
            fileContext.status == 'NO_SOURCE_CELL'
                ? 'Fact ini tidak memiliki source cell untuk dihubungkan ke workbook asli.'
                : 'File XLSX asli belum tersimpan di Storage. Source sheet inspector tetap menggunakan snapshot sel terimpor.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (file != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _TraceField(
                label: 'STATUS',
                value: file.availabilityStatus,
              ),
            ),
        ] else if (file != null) ...[
          const _StatusBadge(label: 'ORIGINAL XLSX AVAILABLE'),
          const SizedBox(height: 8),
          _TraceField(
            label: 'FILE',
            value: file.originalFilename,
          ),
          _TraceField(
            label: 'TYPE',
            value: file.contentType,
          ),
          if (file.byteSize != null)
            _TraceField(
              label: 'SIZE',
              value: _formatBytes(file.byteSize!),
            ),
          if (file.fileSha256 != null)
            _TraceField(
              label: 'SHA-256',
              value: file.fileSha256!,
            ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _opening ? null : () => _openOriginalFile(file),
            icon: _opening
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new),
            label: Text(
              _opening ? 'Membuka workbook…' : 'Buka workbook asli',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Akses memakai signed URL sementara (5 menit). File dibuka sebagai XLSX asli; aplikasi tidak mengirimkannya ke layanan penampil pihak ketiga.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ] else ...[
          const _StatusBadge(label: 'FILE NOT AVAILABLE'),
          const SizedBox(height: 8),
          Text(
            'Metadata file tidak lengkap sehingga workbook asli tidak dapat dibuka.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Future<void> _openOriginalFile(CommanderSourceFile file) async {
    if (file.objectPath.isEmpty) return;

    setState(() => _opening = true);
    try {
      final repository = ref.read(commanderDrilldownRepositoryProvider);
      final signedUrl = await repository.createSourceFileSignedUrl(
        bucketId: file.bucketId,
        objectPath: file.objectPath,
        expiresIn: 300,
      );

      final launched = await launchUrl(
        Uri.parse(signedUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Workbook asli tidak dapat dibuka di browser/perangkat ini.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is AppException
          ? error.message
          : 'Workbook asli tidak dapat dibuka.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }
}

class _SourceSheetContextSection extends ConsumerWidget {
  const _SourceSheetContextSection({
    required this.domainCode,
    required this.recordId,
  });

  final String domainCode;
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      commanderSourceSheetContextProvider(
        CommanderSourceSheetContextQuery(
          domainCode: domainCode,
          recordId: recordId,
        ),
      ),
    );

    return state.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            error is AppException
                ? error.message
                : 'Source sheet context belum dapat dibaca.',
          ),
        ),
      ),
      data: (contextData) => _SourceSheetContextCard(
        contextData: contextData,
      ),
    );
  }
}

class _SourceSheetContextCard extends StatelessWidget {
  const _SourceSheetContextCard({
    required this.contextData,
  });

  final CommanderSourceSheetContext contextData;

  @override
  Widget build(BuildContext context) {
    if (!contextData.found) {
      return const _EmptyCard(
        message: 'Tidak ada source cell yang dapat ditampilkan.',
      );
    }

    final workbook = contextData.workbook;
    final columns = <String>{
      for (final cell in contextData.cells) cell.columnLetter,
    }.toList()
      ..sort(_compareColumnLetters);

    final rows = <int>{
      for (final cell in contextData.cells)
        if (cell.rowNumber != null) cell.rowNumber!,
    }.toList()
      ..sort();

    final cellByPosition = <String, CommanderSourceSheetCell>{
      for (final cell in contextData.cells)
        if (cell.rowNumber != null)
          _positionKey(cell.rowNumber!, cell.columnLetter): cell,
    };

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'SOURCE SHEET INSPECTOR',
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOURCE SHEET INSPECTOR',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              workbook == null
                  ? 'Workbook metadata tidak tersedia.'
                  : workbook.name +
                      ' · ' +
                      workbook.sheet +
                      (workbook.sheetIndex == null
                          ? ''
                          : ' · index ' + workbook.sheetIndex.toString()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _StatusBadge(
                  label: contextData.isAllPomdamContext
                      ? 'ALL-POMDAM CONTEXT'
                      : 'POMDAM CELL CONTEXT',
                ),
                if (contextData.target != null)
                  _StatusBadge(
                    label: 'TARGET ' + contextData.target!.ref,
                  ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              contextData.isAllPomdamContext
                  ? 'Menampilkan konteks sel di sekitar target untuk seluruh kolom yang berhasil diimpor.'
                  : 'Menampilkan hanya kolom POMDAM pemilik fact agar konteks lintas-scope tidak ikut terbuka.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Yang ditampilkan adalah snapshot sel terimpor di database, bukan renderer file XLSX asli.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty || columns.isEmpty)
              const _EmptyCard(
                message: 'Tidak ada sel terimpor pada window ini.',
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 18,
                      headingRowHeight: 42,
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 66,
                      columns: [
                        const DataColumn(label: Text('ROW')),
                        for (final column in columns)
                          DataColumn(
                            label: Text(
                              _columnHeader(column, contextData.cells),
                            ),
                          ),
                      ],
                      rows: [
                        for (final rowNumber in rows)
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  rowNumber.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              for (final column in columns)
                                DataCell(
                                  _SourceSheetCellView(
                                    cell: cellByPosition[
                                      _positionKey(rowNumber, column)
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Tap/click sel untuk melihat raw value, formula, status, dan semantic role.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          ),
        ),
      ),
    );
  }

  String _columnHeader(
    String column,
    List<CommanderSourceSheetCell> cells,
  ) {
    for (final cell in cells) {
      if (cell.columnLetter == column) {
        return cell.columnLabel ?? column;
      }
    }
    return column;
  }
}

class _SourceSheetCellView extends StatelessWidget {
  const _SourceSheetCellView({required this.cell});

  final CommanderSourceSheetCell? cell;

  @override
  Widget build(BuildContext context) {
    if (cell == null) return const SizedBox(width: 84);

    final text = cell!.rawValue ??
        (cell!.parsedNumeric?.toString() ?? '—');

    return InkWell(
      onTap: () => _showCellDetails(context, cell!),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 110,
        constraints: const BoxConstraints(minHeight: 34),
        decoration: BoxDecoration(
          border: Border.all(
            color: cell!.isTarget
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: cell!.isTarget ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _showCellDetails(
    BuildContext context,
    CommanderSourceSheetCell cell,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cell.ref,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 5),
              Text(cell.columnLabel ?? cell.columnLetter),
              const SizedBox(height: 14),
              _TraceField(
                label: 'RAW VALUE',
                value: cell.rawValue ?? '—',
              ),
              _TraceField(
                label: 'PARSED',
                value: cell.parsedNumeric?.toString() ?? '—',
              ),
              _TraceField(
                label: 'STATUS',
                value: cell.dataStatus,
              ),
              _TraceField(
                label: 'ROLE',
                value: cell.semanticRole ?? '—',
              ),
              if (cell.rowLabel != null)
                _TraceField(
                  label: 'ROW LABEL',
                  value: cell.rowLabel!,
                ),
              if (cell.formulaText != null)
                _TraceField(
                  label: 'FORMULA',
                  value: cell.formulaText!,
                ),
              if (cell.isTarget)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: _StatusBadge(label: 'TARGET FACT CELL'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

int _compareColumnLetters(String a, String b) {
  int value(String letter) {
    var total = 0;
    for (final codeUnit in letter.codeUnits) {
      total = total * 26 + codeUnit - 64;
    }
    return total;
  }

  return value(a).compareTo(value(b));
}

String _positionKey(int row, String column) => row.toString() + ':' + column;

class _TraceField extends StatelessWidget {
  const _TraceField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Text(
      error is AppException
          ? (error as AppException).message
          : 'Provenance fact belum dapat dibaca.',
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.retry,
  });

  final Object error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      title: 'Drill-down tidak tersedia',
      message: error is AppException
          ? (error as AppException).message
          : 'Data drill-down belum dapat dibaca dari Supabase.',
      action: FilledButton.icon(
        onPressed: retry,
        icon: const Icon(Icons.refresh),
        label: const Text('Coba lagi'),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_tree_outlined, size: 30),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(message),
                    if (action != null) ...[
                      const SizedBox(height: 14),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return bytes.toString() + ' B';
  if (bytes < 1024 * 1024) {
    return (bytes / 1024).toStringAsFixed(1) + ' KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return (bytes / (1024 * 1024)).toStringAsFixed(1) + ' MB';
  }
  return (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1) + ' GB';
}

String _format(dynamic value) {
  if (value == null) return '—';

  if (value is num) {
    final d = value.toDouble();
    if (d == d.truncateToDouble()) return _group(d.toInt());
    return d.toStringAsFixed(2).replaceAll('.', ',');
  }

  return value.toString();
}

String _group(int value) {
  final sign = value < 0 ? '-' : '';
  final digits = value.abs().toString();
  final parts = <String>[];

  for (var end = digits.length; end > 0; end -= 3) {
    final start = end > 3 ? end - 3 : 0;
    parts.add(digits.substring(start, end));
  }

  return sign + parts.reversed.join('.');
}
