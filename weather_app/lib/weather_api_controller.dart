import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

double lat = -34.9206722;
double long = -57.9561499;

Future<void> fetchWeather() async {

  final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&timezone=auto&forecast_days=1'));

  developer.log('new fetch', name: 'weather.app.temp');

  if (response.statusCode == 200) {
    WeatherState().updateCurrentWeather(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load weather');
  }
}


class WeatherState extends ChangeNotifier {
  String _timezone = "";
  double _temp = 0;
  
  static final WeatherState _currentWeather = WeatherState._internal();
  
  factory WeatherState() {
    return _currentWeather;
  }

  WeatherState._internal();

  void updateCurrentWeather(Map<String, dynamic> json) {
  
    _timezone = json['timezone'];
    _temp = json['current']['temperature_2m'];

    notifyListeners();
  }

  String get timezone => _timezone;
  double get temp => _temp;
}

/*
Geolocation

void getUserLocation() async {
  if (Navigator.geolocation != null) {
    try {
      Position position = await Navigator.geolocation.getCurrentPosition();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } catch (e) {
      print('Error getting user location: $e');
    }
  } else {
    print('Geolocation is not supported by this browser.');
  }
}

void requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}
*/