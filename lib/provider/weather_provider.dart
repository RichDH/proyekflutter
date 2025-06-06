import 'package:flutter/material.dart';
import '../model/weather.dart';
import '../services/weather_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';

  Weather? get weather => _weather;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchWeather() async {
    _state = WeatherState.loading;
    notifyListeners();
    try {
      _weather = await _weatherService.getCurrentWeather();
      _state = WeatherState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WeatherState.error;
    }
    notifyListeners();
  }
}