import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/tts_service.dart';

class MyCropsScreen extends ConsumerWidget {
  const MyCropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);
    final myCrops = repo.getUserCrops();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCrops),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: myCrops.length,
                itemBuilder: (context, index) {
                  final userCrop = myCrops[index];
                  final cropMaster = repo.crops.firstWhere((c) => c.id == userCrop.cropId);
                  final currentStage = repo.getCurrentStageFor(userCrop);
                  final daysSinceSowing = DateTime.now().difference(userCrop.sowingDate).inDays;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.agriculture, size: 36, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang == 'te' ? cropMaster.nameTe : cropMaster.nameEn,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                      ),
                                      Text(
                                        "${userCrop.fieldSizeAcres} ${lang == 'te' ? 'ఎకరాలు' : 'Acres'} • ${userCrop.locationText}",
                                        style: const TextStyle(color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(
                                  "$daysSinceSowing ${lang == 'te' ? 'రోజులు' : 'Days'}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            "${lang == 'te' ? 'ప్రస్తుత దశ' : 'Current Stage'}: ${lang == 'te' ? currentStage.nameTe : currentStage.nameEn}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lang == 'te' ? currentStage.careActionTe : currentStage.careActionEn,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: VoiceButton(
                              text: lang == 'te' ? currentStage.careActionTe : currentStage.careActionEn,
                              itemId: 'user_crop_${userCrop.id}',
                              lang: lang,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BigButton(
                label: l10n.addCrop,
                onPressed: () => context.go('/my-crops/new'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
