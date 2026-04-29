import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/records_provider.dart';

class RecordsAnalysisScreen extends ConsumerWidget {
  const RecordsAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Analysis'),
        centerTitle: true,
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No data to analyze'));
          }

          // ── ANALYSIS ──
          final total = records.length;

          final submitted =
              records.where((r) => r.status == 'submitted').length;
          final resolved = records.where((r) => r.status == 'resolved').length;
          final canceled = records.where((r) => r.status == 'canceled').length;

          final accident = records.where((r) => r.type == 'Accident').length;
          final fire = records.where((r) => r.type == 'Fire').length;
          final crime = records.where((r) => r.type == 'Crime').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(
                context: context,
                title: 'Total Reports',
                value: total,
              ),
              const SizedBox(height: 24),
              _sectionTitle('By Status'),
              _statTile(
                icon: Icons.send,
                label: 'Submitted',
                value: submitted,
              ),
              _statTile(
                icon: Icons.check_circle,
                label: 'Resolved',
                value: resolved,
              ),
              _statTile(
                icon: Icons.cancel,
                label: 'Canceled',
                value: canceled,
              ),
              const SizedBox(height: 24),
              _sectionTitle('By Incident Type'),
              _statTile(
                icon: Icons.car_crash,
                label: 'Accident',
                value: accident,
              ),
              _statTile(
                icon: Icons.local_fire_department,
                label: 'Fire',
                value: fire,
              ),
              _statTile(
                icon: Icons.local_police,
                label: 'Crime',
                value: crime,
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required int value,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
