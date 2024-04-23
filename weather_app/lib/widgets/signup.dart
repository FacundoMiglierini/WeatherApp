import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/controllers/database_controller.dart';

import 'extra_components.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey;

  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _repeatedPasswordController;
  final VoidCallback toggleIndex;
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController repeatedPasswordController,
    required this.toggleIndex,
  }) : _formKey = formKey, _emailController = emailController, _passwordController = passwordController, _repeatedPasswordController = repeatedPasswordController;

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

class RegisterPage extends StatelessWidget {
  final VoidCallback toggleIndex;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  final _repeatedPasswordController = TextEditingController();
  RegisterPage({super.key, required this.toggleIndex});

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
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;


  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
}