import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/database_controller.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:weather_app/weather_controller.dart';


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
        home: const HomePage(),
      ),
    );
  }
}


class AppState extends ChangeNotifier {
  var isLoggedIn = false;

  String logIn(String email, String password) {

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please enter email and password');
      }

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
      return error.toString().replaceAll("Exception: ", ""); 
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
  LoginPage({super.key, required this.toggleIndex});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final VoidCallback toggleIndex;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
    double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center( 
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: deviceWidth(context) > 1126 ? deviceWidth(context) * 0.15 : deviceWidth(context) * 0.08,
              vertical: deviceWidth(context) * 0.08,
            ),
            child: Row(
              children: [
                Visibility(
                  visible: deviceWidth(context) > 874, 
                  child: Expanded( 
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 75),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [  
                            Text(  
                                'Your weather app!',  
                                style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.onBackground),  
                                textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: Image.asset(
                                'assets/weather_logo.png',
                                fit: BoxFit.scaleDown,
                              ),  
                            )
                          ],  
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: deviceWidth(context) > 874, 
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 45),
                    child: VerticalDivider(
                      width: 20,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded( 
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const TitleCard(),
                        LoginForm(emailController: _emailController, passwordController: _passwordController, appState: appState, toggleIndex: toggleIndex),
                      ],
                    ),
                  ),
                ),
              ]
            )
          )
        );
      }
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required this.appState,
    required this.toggleIndex,
  }) : _emailController = emailController, _passwordController = passwordController;

  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final AppState appState;
  final VoidCallback toggleIndex;

  @override
  Widget build(BuildContext context) {
    return Column( 
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            String message = appState.logIn(_emailController.text, _passwordController.text);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 3),
              ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: Size(
              MediaQuery.of(context).size.width,
              40,
            ),
            textStyle: const TextStyle(fontSize: 15),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Log in'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            const Text('Don\'t you have an account? ', style: TextStyle(fontSize: 15)),
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
    );
  }
}
    

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.toggleIndex});

  final VoidCallback toggleIndex;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatedPasswordController = TextEditingController();

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidth(context) > 1126 ? deviceWidth(context) * 0.30 : deviceWidth(context) * 0.08,
            vertical: deviceWidth(context) * 0.08,
          ),
          child: Center(
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const TitleCard(),
                RegisterForm(formKey: _formKey, emailController: _emailController, passwordController: _passwordController, repeatedPasswordController: _repeatedPasswordController, toggleIndex: toggleIndex)])),
        );
      }
    );
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController repeatedPasswordController,
    required this.toggleIndex,
  }) : _formKey = formKey, _emailController = emailController, _passwordController = passwordController, _repeatedPasswordController = repeatedPasswordController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _repeatedPasswordController;
  final VoidCallback toggleIndex;

  @override
  Widget build(BuildContext context) {
    return Form(
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
                contentPadding: EdgeInsets.all(10),
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
                contentPadding: EdgeInsets.all(10),
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
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 30),
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: Size(
                  MediaQuery.of(context).size.width,
                  40,
                ),
                textStyle: const TextStyle(fontSize: 15),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Text('Already have an account? ', style: TextStyle(fontSize: 15)),
                InkWell(
                  onTap: toggleIndex,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ]));
  }
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
  Widget build(BuildContext context) {

    var appState = context.watch<AppState>();

    double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

    return Scaffold( 
      appBar: AppBar(
        title: const Text('Weather App!'),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded( 
                          child: Image.asset('assets/weather_logo.png', fit: BoxFit.cover,),
                        ),
                        const Text('Menu'),
                      ],
                    ),
                  ),
                ),
              ),
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
      body: Center(
        child: loaded ? Padding(
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
                  ) 
                ),
              ),
              const WeatherCard(),
            ],
          ),
        ) : const CircularProgressIndicator(),
      )
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
    final style = deviceWidth(context) > 1000 ? theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold, 
    ) : theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold, 
    );

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Weather App!',
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}


class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
  });

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  
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
}
