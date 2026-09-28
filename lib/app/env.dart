import 'dart:convert';
import 'package:flutter/services.dart';

class Env {
  static String geminiApiKey = 'AIzaSyBBnqnn7KiPNiFgG3Wj0piHpWp8GsdsmXM';
  static String openMeteoBaseUrl = 'https://api.open-meteo.com/v1';
  static String defaultLanguage = 'te';
  static String supportWhatsappNumber = '+919999999999';
  static bool featureFakeDiagnose = false;

  static Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString('assets/env.example.json');
      final data = json.decode(jsonString);
      geminiApiKey = data['GEMINI_API_KEY'] ?? geminiApiKey;
      openMeteoBaseUrl = data['OPEN_METEO_BASE_URL'] ?? openMeteoBaseUrl;
      defaultLanguage = data['DEFAULT_LANGUAGE'] ?? defaultLanguage;
      supportWhatsappNumber = data['SUPPORT_WHATSAPP_NUMBER'] ?? supportWhatsappNumber;
      featureFakeDiagnose = data['FEATURE_FAKE_DIAGNOSE'] ?? featureFakeDiagnose;
    } catch (_) {}
  }
}
