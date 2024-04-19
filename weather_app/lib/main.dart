import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Weather App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          home: MyHomePage(),
        ),
      );
    }
}


class MyAppState extends ChangeNotifier {
  var isLoggedIn = false;
  
  bool logIn(username, password) {
    var ok = true;
    if (ok) {
      isLoggedIn = true;
    }
    notifyListeners();
    return isLoggedIn;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    Widget page = LoginPage();

    return Scaffold(
      body: page,
    );
  }
}

class LoginPage extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var isLoggedIn = appState.isLoggedIn;


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('username'),
          Text('password'),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (appState.logIn("HOLA", "CHAU")) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeatherPage()),
                      );
                  }
                },
                child: Text('Log in'),
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
  
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override 
  Widget build(BuildContext context) {

    return const Center( 
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('WEATHER!'),
        ],
      ),
    );
  }
}