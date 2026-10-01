import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reference_data_providers.dart';

class PomdamPage extends ConsumerWidget {
  const PomdamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomdams = ref.watch(pomdamsProvider);

    return pomdams.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada data POMDAM.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final pomdam = items[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(pomdam.reportOrder.toString()),
                ),
                title: Text(
                  pomdam.code + ' · ' + pomdam.shortName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(pomdam.pomdamFullName),
                trailing: pomdam.active
                    ? const Chip(label: Text('ACTIVE'))
                    : const Chip(label: Text('INACTIVE')),
              ),
            );
          },
        );
      },
    );
  }
}
