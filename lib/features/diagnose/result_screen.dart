import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mana_pantalu/app/env.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/tts_service.dart';

class ResultScreen extends ConsumerWidget {
  final String scanId;
  const ResultScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);
    final scan = repo.getScan(scanId);

    final crop = repo.crops.firstWhere((c) => c.id == (scan?.cropId ?? 'rice'));
    final disease = scan?.diseaseId != null ? repo.diseases[scan!.diseaseId] : null;

    final String speechText = disease != null
        ? "${crop.nameTe}. సమస్య: ${disease.nameTe}. లక్షణాలు: ${disease.symptomsTe.join(', ')}. చికిత్స: ${disease.treatmentTe.join(', ')}"
        : "ఖచ్చితంగా చెప్పలేకపోతున్నాం. దయచేసి మళ్ళీ ఫోటో తీయండి.";

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnose),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.grass, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${l10n.detectedCrop}: ${lang == 'te' ? crop.nameTe : crop.nameEn}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              disease != null
                                  ? "${l10n.possibleIssue}: ${lang == 'te' ? disease.nameTe : disease.nameEn}"
                                  : l10n.notSure,
                              style: TextStyle(
                                fontSize: 16,
                                color: disease != null ? AppColors.primaryDark : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                "${((scan?.confidence ?? 0.90) * 100).toInt()}% Match",
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VoiceButton(
                    text: speechText,
                    itemId: 'result_$scanId',
                    lang: lang,
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/diagnose'),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.scanAgain),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (disease != null) ...[
                SectionCard(
                  title: l10n.symptoms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (lang == 'te' ? disease.symptomsTe : disease.symptomsEn)
                        .map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("• $s", style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
                SectionCard(
                  title: l10n.causes,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (lang == 'te' ? disease.causesTe : disease.causesEn)
                        .map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("• $c", style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
                SectionCard(
                  title: l10n.prevention,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (lang == 'te' ? disease.preventionTe : disease.preventionEn)
                        .map((p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("• $p", style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
                SectionCard(
                  title: l10n.treatment,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (lang == 'te' ? disease.treatmentTe : disease.treatmentEn)
                        .map((t) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("• $t", style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
              ] else ...[
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.notSure,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                        const SizedBox(height: 12),
                        BigButton(
                          label: l10n.retake,
                          onPressed: () => context.go('/diagnose'),
                        ),
                        const SizedBox(height: 12),
                        BigButton(
                          label: l10n.askExpert,
                          isSecondary: true,
                          onPressed: () async {
                            final uri = Uri.parse("https://wa.me/${Env.supportWhatsappNumber}");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.trustNote,
                        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
