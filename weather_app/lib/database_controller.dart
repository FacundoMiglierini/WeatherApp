import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:developer' as developer;
import 'dart:convert';


class DatabaseHelper {

  var usersBox = Hive.box<String>('user');
  
  bool isValidUser(String email, String password) {

    var storedEmail = usersBox.get('email');
    var storedPassword = usersBox.get('password');
    
    if (storedEmail == null || storedPassword == null) {
      return false;
    } 
    
    final bytes = utf8.encode(password);
    String hashedPassword = sha256.convert(bytes).toString();

    developer.log("Email: $email - Password: $hashedPassword", name: 'weather.app.database');

    developer.log("Email: $storedEmail - Password: $storedPassword", name: 'weather.app.database');
    
    return email == storedEmail && hashedPassword == storedPassword;
  } 
  
  bool insertUser(String email, String password) {

    final bytes = utf8.encode(password);
    String hashedPassword = sha256.convert(bytes).toString();
    usersBox.put('email', email);
    usersBox.put('password', hashedPassword);
    
    String? getEmail = usersBox.get('email');
    String? getPassword = usersBox.get('password');

    developer.log("Email: $email - Password: $hashedPassword", name: 'weather.app.database');

    developer.log("Email: $getEmail - Password: $getPassword", name: 'weather.app.database');
    
    return true;
  }
}