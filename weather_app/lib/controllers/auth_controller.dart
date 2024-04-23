import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/controllers/database_controller.dart';

class AuthState extends ChangeNotifier {
  var isLoggedIn = false;

  String logIn(String email, String password) {

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please enter email and password');
      }

      if (!EmailValidator.validate(email)) {
        throw Exception('Invalid email format');
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