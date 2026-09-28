import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/core/repository.dart';
import 'package:mana_pantalu/core/widgets.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/notification_service.dart';

class AddCropScreen extends ConsumerStatefulWidget {
  const AddCropScreen({super.key});

  @override
  ConsumerState<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends ConsumerState<AddCropScreen> {
  String selectedCropId = 'rice';
  DateTime sowingDate = DateTime.now().subtract(const Duration(days: 10));
  double fieldSize = 1.5;
  String location = 'Guntur';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final repo = ref.watch(repositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCrop),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'te' ? 'పంటను ఎంచుకోండి' : 'Select Crop',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCropId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: repo.crops.map((crop) {
                  return DropdownMenuItem(
                    value: crop.id,
                    child: Text(lang == 'te' ? crop.nameTe : crop.nameEn),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCropId = val);
                },
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sowingDate,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppColors.surface,
                title: Text("${sowingDate.day}/${sowingDate.month}/${sowingDate.year}"),
                trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: sowingDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => sowingDate = picked);
                },
              ),
              const SizedBox(height: 20),
              Text(
                l10n.fieldSize,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, size: 36, color: AppColors.primary),
                    onPressed: () {
                      if (fieldSize > 0.5) setState(() => fieldSize -= 0.5);
                    },
                  ),
                  Text(
                    "$fieldSize ${lang == 'te' ? 'ఎకరాలు' : 'Acres'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 36, color: AppColors.primary),
                    onPressed: () {
                      setState(() => fieldSize += 0.5);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.location,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                  hintText: 'e.g. Guntur',
                ),
                onChanged: (val) => location = val,
              ),
              const SizedBox(height: 32),
              BigButton(
                label: l10n.save,
                onPressed: () async {
                  final userCrop = UserCrop(
                    id: "uc_${DateTime.now().millisecondsSinceEpoch}",
                    cropId: selectedCropId,
                    sowingDate: sowingDate,
                    fieldSizeAcres: fieldSize,
                    locationText: location,
                  );
                  repo.addUserCrop(userCrop);

                  await NotificationService.instance.scheduleNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: 'Mana Pantalu - Crop Care',
                    body: 'Your crop has entered a new stage. Check recommendations!',
                    scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
                  );

                  if (mounted) {
                    context.go('/my-crops');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
