import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'extra_components.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController _emailController;

  final TextEditingController _passwordController;
  final AuthState appState;
  final VoidCallback toggleIndex;
  const LoginForm({
    super.key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required this.appState,
    required this.toggleIndex,
  }) : _emailController = emailController, _passwordController = passwordController;

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

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  final VoidCallback toggleIndex;

  LoginPage({super.key, required this.toggleIndex});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AuthState>();

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