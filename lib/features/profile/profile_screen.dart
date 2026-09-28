import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "రైతు సోదరుడు (Farmer)",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentLang == 'te' ? 'అతిథి వినియోగదారు' : 'Guest User',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: Text(l10n.language),
                trailing: DropdownButton<String>(
                  value: currentLang,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(localeProvider.notifier).setLocale(val);
                    }
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: AppColors.primary),
                title: Text(l10n.scanHistory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/profile/history'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.feedback, color: AppColors.primary),
                title: Text(l10n.feedback),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/profile/feedback'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_android, color: AppColors.primary),
                title: Text(l10n.signInPhone),
                subtitle: Text(currentLang == 'te' ? 'డేటా భద్రత కోసం ఫోన్ సంఖ్యతో లాగిన్ చేయండి' : 'Sign in to save data across devices'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(currentLang == 'te' ? 'ఫోన్ లాగిన్ త్వరలో రానుంది' : 'Phone sign in coming soon')),
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
