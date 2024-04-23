import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'widgets/login.dart';
import 'widgets/signup.dart';
import 'widgets/weather.dart';


void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>('user');

  runApp(const WeatherApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthState(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<AuthState>();
    var isLoggedIn = appState.isLoggedIn;
    
    Widget page;
    
    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const WeatherPage(),
          ),
        );
      });
    }
    
    switch (selectedIndex) {
      case 0:
        page = LoginPage(toggleIndex: toggleIndex);
      case 1:
        page = RegisterPage(toggleIndex: toggleIndex);
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
  
  void toggleIndex() {
    setState(() {
      selectedIndex = 1 - selectedIndex;
    });
  }
}