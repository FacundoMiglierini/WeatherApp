import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/database_controller.dart';
import 'dart:async';
import 'weather_api_controller.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

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
              ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: HomePage(),
      ),
    );
  }
}


class AppState extends ChangeNotifier {
  var isLoggedIn = false;
  var temp = 0;

  bool logIn(String email, String password){

    try {
      if (!EmailValidator.validate(email)) {
        throw const FormatException('Invalid email format');
      }
      
      if (!DatabaseHelper().isValidUser(email, password)) {
        throw Exception('Invalid email or password');
      }

      isLoggedIn = true;

      notifyListeners();
      return true;
    } catch (error) {
      //emit(LoginFailure(error: error.toString()));
      return false;
    }
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
      page = WeatherPage();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
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
    
    return Center( 
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if(!appState.logIn(_emailController.text, _passwordController.text)) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text("Invalid credentials."),
                        duration: Duration(seconds: 3),
                      ));
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text("Welcome!"),
                        duration: Duration(seconds: 3),
                      ));
                  }
                },
                child: const Text('Login'),
              ),
              SizedBox(width: 10),
              Text('Don\'t you have an account? '),
              InkWell(
                onTap: toggleIndex,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ],
          ),
        ]
      )
    );
  }
}
    
    /*
    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 3),
              ));
          }
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Welcome!'),
                duration: Duration(seconds: 1),
              ));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => WeatherState(),
                  child: const WeatherPage()),
                )
            );
          }
        },
        child: Row(
          children: [
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                        onPressed: state is! LoginLoading
                            ? () {
                                loginBloc.add(
                                  LoginButtonPressed(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            : null,
                        child: const Text('Login'),
                      ),
                      if (state is LoginLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterForm()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


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

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WeatherCard(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage()),
                );
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Card(
      color: theme.colorScheme.background,
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
  const WeatherCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<WeatherState>();
    var temp = appState.temp;

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );

    return Card(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '$temp grados',
          style: style,
        ),
      ),
    );
  }
}
