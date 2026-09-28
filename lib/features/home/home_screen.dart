import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/tts_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);
    final todayTip = repo.tips.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, size: 28),
            onPressed: () {
              ref.read(localeProvider.notifier).toggle();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.greeting,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  VoiceButton(
                    text: lang == 'te' ? "నమస్కారం! మన పంటలు యాప్‌కి స్వాగతం." : "Hello! Welcome to Mana Pantalu.",
                    itemId: 'greeting',
                    lang: lang,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  IconTile(
                    title: l10n.diagnose,
                    icon: Icons.camera_alt,
                    onTap: () => context.go('/diagnose'),
                  ),
                  IconTile(
                    title: l10n.weather,
                    icon: Icons.cloud,
                    onTap: () => context.go('/weather'),
                  ),
                  IconTile(
                    title: l10n.cropLibrary,
                    icon: Icons.grass,
                    onTap: () => context.go('/crops'),
                  ),
                  IconTile(
                    title: l10n.tips,
                    icon: Icons.lightbulb,
                    onTap: () => context.go('/tips'),
                  ),
                  IconTile(
                    title: l10n.myCrops,
                    icon: Icons.agriculture,
                    onTap: () => context.go('/my-crops'),
                  ),
                  IconTile(
                    title: l10n.help,
                    icon: Icons.help_outline,
                    onTap: () => context.go('/profile/feedback'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: AppColors.surface,
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
                              const Icon(Icons.star, color: Colors.orange, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                lang == 'te' ? todayTip.titleTe : todayTip.titleEn,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          VoiceButton(
                            text: lang == 'te' ? todayTip.bodyTe : todayTip.bodyEn,
                            itemId: 'tip_today',
                            lang: lang,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang == 'te' ? todayTip.bodyTe : todayTip.bodyEn,
                        style: const TextStyle(fontSize: 16, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
