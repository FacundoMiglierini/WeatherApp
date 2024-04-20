import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

//String apiKey = "ecadab7967182ce975aa7d730cf32eef";
double lat = -34.9206722;
double long = -57.9561499;

Future<void> fetchWeather() async {
  //final response = await http.get(Uri.parse('https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,daily,alerts&appid=$apiKey'));

  final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&timezone=auto&forecast_days=1'));

  if (response.statusCode == 200) {
    WeatherState().updateCurrentWeather(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    
    var statusCode = response.statusCode;
    developer.log('$statusCode', name: 'weather.app.temp');
    throw Exception('Failed to load weather');
  }
}

Stream<void> callWeatherApi() {
  return Stream.periodic(const Duration(minutes: 1), (_) {
    fetchWeather();
  });
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


    developer.log('$temp degrees', name: 'weather.app.temp');

    notifyListeners();
  }

  String get timezone => _timezone;
  double get temp => _temp;
}

/*
{
   "lat":33.44,
   "lon":-94.04,
   "timezone":"America/Chicago",
   "timezone_offset":-18000,
   "current":{
      "dt":1684929490,
      "sunrise":1684926645,
      "sunset":1684977332,
      "temp":292.55,
      "feels_like":292.87,
      "pressure":1014,
      "humidity":89,
      "dew_point":290.69,
      "uvi":0.16,
      "clouds":53,
      "visibility":10000,
      "wind_speed":3.13,
      "wind_deg":93,
      "wind_gust":6.71,
      "weather":[
         {
            "id":803,
            "main":"Clouds",
            "description":"broken clouds",
            "icon":"04d"
         }
      ]
   },

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