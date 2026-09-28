import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mana_pantalu/core/providers.dart';
import 'package:mana_pantalu/features/welcome/welcome_screen.dart';
import 'package:mana_pantalu/features/home/home_screen.dart';
import 'package:mana_pantalu/features/diagnose/capture_screen.dart';
import 'package:mana_pantalu/features/diagnose/scan_screen.dart';
import 'package:mana_pantalu/features/diagnose/result_screen.dart';
import 'package:mana_pantalu/features/weather/weather_screen.dart';
import 'package:mana_pantalu/features/crops/crops_screen.dart';
import 'package:mana_pantalu/features/crops/crop_detail_screen.dart';
import 'package:mana_pantalu/features/tips/tips_screen.dart';
import 'package:mana_pantalu/features/my_crops/my_crops_screen.dart';
import 'package:mana_pantalu/features/my_crops/add_crop_screen.dart';
import 'package:mana_pantalu/features/profile/profile_screen.dart';
import 'package:mana_pantalu/features/profile/feedback_screen.dart';
import 'package:mana_pantalu/features/profile/scan_history_screen.dart';
import 'package:mana_pantalu/app/shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final welcomeSeen = ref.watch(welcomeSeenProvider);

  return GoRouter(
    initialLocation: welcomeSeen ? '/home' : '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/diagnose',
            builder: (context, state) => const CaptureScreen(),
            routes: [
              GoRoute(
                path: 'scan/:scanId',
                builder: (context, state) {
                  final scanId = state.pathParameters['scanId']!;
                  return ScanScreen(scanId: scanId);
                },
              ),
              GoRoute(
                path: 'result/:scanId',
                builder: (context, state) {
                  final scanId = state.pathParameters['scanId']!;
                  return ResultScreen(scanId: scanId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my-crops',
            builder: (context, state) => const MyCropsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const AddCropScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/tips',
            builder: (context, state) => const TipsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'feedback',
                builder: (context, state) => const FeedbackScreen(),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const ScanHistoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherScreen(),
          ),
          GoRoute(
            path: '/crops',
            builder: (context, state) => const CropsScreen(),
            routes: [
              GoRoute(
                path: ':cropId',
                builder: (context, state) {
                  final cropId = state.pathParameters['cropId']!;
                  return CropDetailScreen(cropId: cropId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
