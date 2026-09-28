import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/weather_service.dart';
import 'package:mana_pantalu/services/tts_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final weatherFutureProvider = FutureProvider((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return await service.getWeather(16.3067, 80.4365); // Guntur default
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(localeProvider);
    final weatherAsync = ref.watch(weatherFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weather),
      ),
      body: SafeArea(
        child: weatherAsync.when(
          data: (data) {
            final current = data['current'];
            final daily = data['daily'];
            final temp = current['temperature_2m'];
            final humidity = current['relative_humidity_2m'];
            final wind = current['wind_speed_10m'];
            final rainChance = daily['precipitation_probability_max'][0];

            String alertTextTe = "రేపు వర్షం వచ్చే అవకాశం ఉంది ($rainChance%). మందు పిచికారీ వాయిదా వేయండి.";
            String alertTextEn = "Rain likely tomorrow ($rainChance%). Delay spraying chemicals.";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("గుంటూరు (Guntur)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("$temp°C", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                ],
                              ),
                              const Icon(Icons.wb_sunny, size: 70, color: Colors.orange),
                            ],
                          ),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.blue),
                                  const SizedBox(height: 4),
                                  Text("$humidity%", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text("తేమ (Humidity)", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.air, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Text("$wind km/h", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text("గాలి (Wind)", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.umbrella, color: Colors.indigo),
                                  const SizedBox(height: 4),
                                  Text("$rainChance%", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text("వర్షం (Rain)", style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning, color: AppColors.warning),
                                  SizedBox(width: 8),
                                  Text("హెచ్చరిక (Alert)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              VoiceButton(
                                text: lang == 'te' ? alertTextTe : alertTextEn,
                                itemId: 'weather_alert',
                                lang: lang,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang == 'te' ? alertTextTe : alertTextEn,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(l10n.noInternet)),
        ),
      ),
    );
  }
}
