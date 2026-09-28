import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation',
          'daily': 'precipitation_probability_max,temperature_2m_max,temperature_2m_min',
          'timezone': 'Asia/Kolkata',
          'forecast_days': 3,
        },
      );
      return response.data;
    } catch (_) {
      return {
        "current": {
          "temperature_2m": 31,
          "relative_humidity_2m": 78,
          "wind_speed_10m": 14,
          "precipitation": 0
        },
        "daily": {
          "precipitation_probability_max": [60, 20, 10],
          "temperature_2m_max": [33, 34, 32],
          "temperature_2m_min": [24, 25, 23]
        }
      };
    }
  }
}
