import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_app/controllers/weather_controller.dart';

import '../controllers/auth_controller.dart';
import '../main.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorText = WeatherStats().isDay() ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.surface;
    final style = deviceWidth(context) > 400 ? theme.textTheme.displayMedium!.copyWith(
      color: colorText,
    ) : theme.textTheme.displaySmall!.copyWith(
      color: colorText
    );

    return Column(
      children: [
        Card(
          color: WeatherStats().isDay() ? theme.colorScheme.primaryContainer : theme.colorScheme.onSurfaceVariant,
          child: Container(
            constraints: deviceWidth(context) > 400 ? const BoxConstraints.tightFor(width: double.infinity, height: 200) : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      WeatherStats().getWeatherAsset() ?? 'assets/weather_logo.png',
                      fit: BoxFit.scaleDown,
                    )
                  ),
                  Expanded( 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          WeatherStats().getTemp(),
                          style: style,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          WeatherStats().getWeather(),
                          style: TextStyle(
                            fontSize: 16, 
                            color: colorText,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card( 
          color: WeatherStats().isDay() ? theme.colorScheme.secondaryContainer : theme.colorScheme.onSurface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apparent temperature',
                        style: TextStyle(
                          fontSize: 16, 
                          color: colorText,
                        ),
                    ),
                    Text(
                      WeatherStats().getApparentTemp(),
                      style: TextStyle(
                        fontSize: 16, 
                        color: colorText,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Relative humidity',
                      style: TextStyle(
                        fontSize: 16, 
                        color: colorText,
                      ),
                    ),
                    Text(
                      WeatherStats().getHumidity(),
                      style: TextStyle(
                        fontSize: 16, 
                        color: colorText,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day / Night',
                      style: TextStyle(
                        fontSize: 16, 
                        color: colorText,
                      ),
                    ),
                    Text(
                      WeatherStats().isDay() ? 'Day' : 'Night',
                      style: TextStyle(
                        fontSize: 16, 
                        color: colorText,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        )
      ],
    );
  }
  
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
}


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override 
  State<WeatherPage> createState() => _WeatherPageState();
}


class _WeatherPageState extends State<WeatherPage>{
  Timer? _timer;
  var loaded = false;

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<AuthState>();

    double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

    return Scaffold( 
      appBar: AppBar(
        title: const Text('Weather App!'),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: ListView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            children: [
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Log out'),
                onTap: () {
                  showAlertDialog(BuildContext context) {  
                    Widget cancelButton = TextButton(
                      child: const Text("No"),
                      onPressed:  () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                    Widget continueButton = TextButton(
                      child: const Text("Yes"),
                      onPressed:  () {
                        appState.logOut();              
                        Navigator.pushReplacement<void, void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const HomePage(),
                          ),
                        );
                      },
                    );  
                    AlertDialog alert = AlertDialog(
                      title: const Text('Log out'),
                      content: const Text('Are you sure to log out?'),
                      actions: [
                        cancelButton,
                        continueButton,
                      ],
                    ); 
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  }
                  showAlertDialog(context);
                },
              ),
            ],
        )
      ),
      body: loaded ? SingleChildScrollView( 
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: deviceWidth(context) > 1126 ? deviceWidth(context) * 0.30 : deviceWidth(context) * 0.08,
              vertical: deviceWidth(context) * 0.08,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text( 
                    'City: ${WeatherStats().getCity()}',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.normal, 
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const WeatherCard(),
              ],
            ),
          ),
        ),
      ) : const Center( 
        child: CircularProgressIndicator(),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> fetchWeather() async {
      final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=${WeatherStats().getLat()}&longitude=${WeatherStats().getLong()}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code&timezone=auto&forecast_days=1'));
      
      developer.log('new fetch');

      if (response.statusCode == 200) {
        setState(() {
          WeatherStats().loadFromJson(jsonDecode(response.body) as Map<String, dynamic>);
          loaded = true;
        });
      }
    }

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchWeather();
    });
  }
}
