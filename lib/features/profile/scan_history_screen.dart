import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';

class ScanHistoryScreen extends ConsumerWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);
    final history = repo.getScanHistory();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanHistory),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Text(
                  lang == 'te' ? 'గత పరీక్షలు ఏవీ లేవు' : 'No past scans found',
                  style: const TextStyle(fontSize: 18, color: AppColors.textMuted),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final scan = history[index];
                  final crop = repo.crops.firstWhere((c) => c.id == (scan.cropId ?? 'rice'));
                  final disease = scan.diseaseId != null ? repo.diseases[scan.diseaseId] : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.history, color: Colors.white),
                      ),
                      title: Text(
                        "${lang == 'te' ? crop.nameTe : crop.nameEn} - ${disease != null ? (lang == 'te' ? disease.nameTe : disease.nameEn) : l10n.notSure}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year} • ${((scan.confidence) * 100).toInt()}% Confidence",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/diagnose/result/${scan.scanId}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
