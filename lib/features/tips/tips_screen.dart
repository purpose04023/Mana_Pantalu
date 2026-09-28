import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/tts_service.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);

    final filteredTips = selectedCategory == 'all'
        ? repo.tips
        : repo.tips.where((t) => t.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tips),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(lang == 'te' ? 'అన్నీ' : 'All'),
                    selected: selectedCategory == 'all',
                    onSelected: (_) => setState(() => selectedCategory = 'all'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(lang == 'te' ? 'పంట సంరక్షణ' : 'Crop Care'),
                    selected: selectedCategory == 'crop_care',
                    onSelected: (_) => setState(() => selectedCategory = 'crop_care'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(lang == 'te' ? 'ఎరువులు' : 'Fertilizer'),
                    selected: selectedCategory == 'fertilizer',
                    onSelected: (_) => setState(() => selectedCategory = 'fertilizer'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(lang == 'te' ? 'నీటి యాజమాన్యం' : 'Irrigation'),
                    selected: selectedCategory == 'irrigation_weather',
                    onSelected: (_) => setState(() => selectedCategory = 'irrigation_weather'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTips.length,
                itemBuilder: (context, index) {
                  final tip = filteredTips[index];
                  final isSaved = repo.getSavedTips().contains(tip.id);

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
                              Text(
                                lang == 'te' ? tip.titleTe : tip.titleEn,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                              IconButton(
                                icon: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    repo.toggleSaveTip(tip.id);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang == 'te' ? tip.bodyTe : tip.bodyEn,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: VoiceButton(
                              text: lang == 'te' ? tip.bodyTe : tip.bodyEn,
                              itemId: 'tip_${tip.id}',
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
          ],
        ),
      ),
    );
  }
}
