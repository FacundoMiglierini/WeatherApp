import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
            ),
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
   @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of < LoginBloc > (context);

    return Scaffold(
      body: BlocListener < LoginBloc, LoginState > (
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
              SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 3),
              )
            );
          }
        },
        child: BlocBuilder < LoginBloc, LoginState > (
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: < Widget > [
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
                    onPressed: state is ! LoginLoading ? () {
                      loginBloc.add(
                        LoginButtonPressed(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                    } : null,
                    child: const Text('Login'),
                  ),
                  if (state is LoginLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/*
class Login extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var isLoggedIn = appState.isLoggedIn;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (appState.logIn(username, password)) {
                Navigator.push( 
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherPage()),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
*/
  
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override 
  Widget build(BuildContext context) {

    return Center( 
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('WEATHER!'),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Log out'),
          ),
        ],
      ),
    );
  }
}