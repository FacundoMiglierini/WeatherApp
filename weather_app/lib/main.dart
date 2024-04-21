import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/database_controller.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>('user');

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: HomePage(),
      ),
    );
  }
}


class AppState extends ChangeNotifier {
  var isLoggedIn = false;

  String logIn(String email, String password) {

    try {
      if (!EmailValidator.validate(email)) {
        throw const FormatException('Invalid email format');
      }
      
      if (!DatabaseHelper().isValidUser(email, password)) {
        throw Exception('Invalid email or password');
      }

      isLoggedIn = true;

      notifyListeners();
      return "Welcome!";
    } catch (error) {
      notifyListeners();
      return error.toString();
    }
  }
  
  void logOut() {
    isLoggedIn = false;
    notifyListeners();
  }
  
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var selectedIndex = 0;

  void toggleIndex() {
    setState(() {
      selectedIndex = 1 - selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<AppState>();
    var isLoggedIn = appState.isLoggedIn;
    
    Widget page;
    
    if (!isLoggedIn) {
      switch (selectedIndex) {
        case 0:
          page = LoginPage(toggleIndex: toggleIndex);
        case 1:
          page = RegisterPage(toggleIndex: toggleIndex);
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }
    } else {
      selectedIndex = 0;
      page = WeatherPage();
    }
    
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
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
    });
  }
}


class LoginPage extends StatelessWidget {
  LoginPage({Key? key, required this.toggleIndex}) : super(key: key);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final VoidCallback toggleIndex;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
    double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
    
    return Center( 
      child: Padding(
        padding: EdgeInsets.only(
          left: deviceWidth(context) * 0.08,
          right: deviceWidth(context) * 0.08,
        ),
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleCard(),
            SizedBox(height: 10),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String message = appState.logIn(_emailController.text, _passwordController.text);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(message),
                    duration: Duration(seconds: 3),
                  ));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: Size(
                  // Set the width of the button to be the same as the text field
                  MediaQuery.of(context).size.width,
                  // Set the height of the button
                  50,
                ),
                textStyle: TextStyle(fontSize: 20),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text('Log in'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Text('Don\'t you have an account? ', style: TextStyle(fontSize: 15)),
                InkWell(
                  onTap: toggleIndex,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ]
        ),
      )
    );
  }
}
    

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key, required this.toggleIndex}) : super(key: key);

  final VoidCallback toggleIndex;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatedPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid email';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Email address is not valid';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Please enter a password that contains at least 8 characters';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _repeatedPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'The password you entered is different';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (DatabaseHelper().insertUser(
                            _emailController.text, _passwordController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('New user registered successfully')),
                          );
                          toggleIndex();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Check errors and try again')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? '),
                      InkWell(
                        onTap: toggleIndex,
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  )
                ]))]));
  }
}


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override 
  State<WeatherPage> createState() => _WeatherPageState();
}


class _WeatherPageState extends State<WeatherPage>{
  Timer? _timer;
  var _temp = 0.0;
  double lat = -34.9206722;
  double long = -57.9561499;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchWeather();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> fetchWeather() async {
      final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&timezone=auto&forecast_days=1'));

      if (response.statusCode == 200) {
        setState(() {
          var json = jsonDecode(response.body) as Map<String, dynamic>;
          _temp = json['current']['temperature_2m'];
        });
      }
    }

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<AppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WeatherCard(temp: _temp),
          ElevatedButton.icon(
            onPressed: () {
              appState.logOut();              
            }, 
            icon: Icon(Icons.logout), 
            label: Text('Log out')),
        ],
      ),
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
  });


  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = deviceWidth(context) > 380 ? theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    ) : theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Weather App!',
          style: style,
        ),
      ),
    );
  }
}


class WeatherCard extends StatelessWidget {
  WeatherCard({
    super.key,
    required this.temp,
  });
  
  var temp = 0.0;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );

    return Card(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '$temp',
          style: style,
        ),
      ),
    );
  }
}
