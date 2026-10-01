import 'package:flutter/material.dart';

class DataQualityPage extends StatelessWidget {
  const DataQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Data quality contract',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Aplikasi mempertahankan status fakta dan tidak mengubah nilai source menjadi nol ketika source kosong atau invalid.',
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Chip(label: Text('VALID')),
            Chip(label: Text('NOT_REPORTED')),
            Chip(label: Text('INVALID_SOURCE')),
            Chip(label: Text('ESTIMATED')),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.source_outlined),
                  title: Text('Source fidelity'),
                  subtitle: Text(
                    'Workbook, sheet, cell, and source provenance remain a data-layer concern.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.security_outlined),
                  title: Text('Security'),
                  subtitle: Text(
                    'The client does not use service-role credentials or bypass RLS.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.schema_outlined),
                  title: Text('Schema'),
                  subtitle: Text(
                    'The application consumes the existing Supabase schema; it does not invent a parallel schema.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
