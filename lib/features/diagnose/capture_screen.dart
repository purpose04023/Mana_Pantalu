import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/tts_service.dart';

final selectedImageProvider = StateProvider<File?>((ref) => null);
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        ref.read(selectedImageProvider.notifier).state = file;
        ref.read(isAnalyzingProvider.notifier).state = true;

        final repo = ref.read(repositoryProvider);
        final result = await repo.diagnoseImage(file);

        ref.read(isAnalyzingProvider.notifier).state = false;

        if (context.mounted) {
          context.go('/diagnose/result/${result.scanId}');
        }
      }
    } catch (_) {
      ref.read(isAnalyzingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final isAnalyzing = ref.watch(isAnalyzingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnose),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lang == 'te' ? 'ఒక ఆకును ఫ్రేమ్‌లో స్పష్టంగా ఉంచండి' : 'Place one leaf clearly inside the frame',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  VoiceButton(
                    text: lang == 'te' ? 'ఒక ఆకును ఫ్రేమ్‌లో స్పష్టంగా ఉంచండి. మంచి వెలుతురులో తీయండి.' : 'Place one leaf inside the frame in good lighting.',
                    itemId: 'capture_guide',
                    lang: lang,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 2, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: isAnalyzing
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 20),
                              Text(
                                l10n.scanning,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.center_focus_strong,
                                size: 100,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                lang == 'te' ? 'మంచి వెలుతురు • దగ్గరగా • ఒకే ఆకు' : 'Good light • Close up • Single leaf',
                                style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BigButton(
                label: l10n.takePhoto,
                icon: Icons.camera_alt,
                onPressed: isAnalyzing ? null : () => _pickImage(context, ref, ImageSource.camera),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: l10n.pickGallery,
                icon: Icons.photo_library,
                isSecondary: true,
                onPressed: isAnalyzing ? null : () => _pickImage(context, ref, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
