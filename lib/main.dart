import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mana_pantalu/app/env.dart';
import 'package:mana_pantalu/app/router.dart';
import 'package:mana_pantalu/app/theme.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/l10n/app_localizations.dart';
import 'package:mana_pantalu/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();

  try {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  } catch (_) {}

  await NotificationService.instance.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ManaPantaluApp(),
    ),
  );
}

class ManaPantaluApp extends ConsumerWidget {
  const ManaPantaluApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Mana Pantalu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(lang),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('te', ''),
        Locale('en', ''),
      ],
      routerConfig: router,
    );
  }
}
