
class WeatherStats {

  String _tempUnit = '';
  String _apparentTempUnit = '';
  String _humidityUnit = '';
  double _temp = 0;
  double _apparentTemp = 0;
  int _humidity = 0;
  int _isDay = 0;  
  int _weatherCode = 0;

  final Map<String, List<int>> _weatherCodes = {
    'Clear sky': [0,1,2,3],
    'Rain': [61,63,65,66,67,80,81,82],
    'Thunderstorm': [95,96,99],
    'Snow fall': [71,73,75,77],
  };
  
  final Map<String, Map<String, String>> _weatherImages = {
    'Clear sky': {
      'day' : 'assets/clear_sky_day.png',
      'night' : 'assets/clear_sky_night.png',
    },
    'Rain': {
      'day' : 'assets/rain_day.png',
      'night' : 'assets/rain_night.png',
    },
    'Thunderstorm': {
      'day' : 'assets/thunderstorm_day.png',
      'night' : 'assets/thunderstorm_night.png',
    },
    'Snow fall': {
      'day' : 'assets/snowfall_day.png',
      'night' : 'assets/snowfall_night.png',
    }
  };

  //Hardcoded city coordinates and name 
  final double _lat = -34.9206722;
  final double _long = -57.9561499;
  final String _city = 'La Plata, Argentina';

  static final WeatherStats _singleton = WeatherStats._();

  factory WeatherStats() => _singleton;
  
  WeatherStats._();

  void loadFromJson(json) {
    _tempUnit = json['current_units']['temperature_2m'];
    _humidityUnit = json['current_units']['relative_humidity_2m'];
    _apparentTempUnit = json['current_units']['apparent_temperature'];
    _temp = json['current']['temperature_2m'];
    _humidity = json['current']['relative_humidity_2m'];
    _apparentTemp = json['current']['apparent_temperature'];
    _isDay = json['current']['is_day'];
    _weatherCode = json['current']['weather_code'];
  }
  
  String getTemp() {
    return '$_temp$_tempUnit';
  }
  
  String getApparentTemp() {
    return '$_apparentTemp$_apparentTempUnit';
  }

  String getHumidity() {
    return '$_humidity$_humidityUnit';
  }
  
  bool isDay() {
    return _isDay == 1 ? true : false;
  }
  
  String getWeather() {
    for (String weather in _weatherCodes.keys) {
      if (_weatherCodes[weather]!.contains(_weatherCode)) {
        return weather;
      }
    }
    
    return 'Unknown weather';
  }
  
  String? getWeatherAsset() {
    String day = isDay() ? 'day' : 'night';
    
    String weather = getWeather();
    if (_weatherImages.containsKey(weather)) {
      return _weatherImages[weather]?[day];
    }
    
    return 'assets/weather_logo.png';
  }
  
  double getLat() {
    return _lat;
  }

  double getLong() {
    return _long;
  }
  
  String getCity() {
    return _city;
  } 
}