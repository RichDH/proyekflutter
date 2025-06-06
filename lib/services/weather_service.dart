import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import '../model/weather.dart';

class WeatherService {
  final String apiKey = '5980aa782756a3c0af62d89cab85681e';
  final LocationService _locationService = LocationService();

  Future<Weather> getCurrentWeather() async {
    try {
      Position position = await _locationService.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Weather.fromJson(jsonResponse);
      } else {
        throw Exception('gagal load data');
      }
    } catch (e) {
      throw Exception('Error fetch data: $e');
    }
  }
}