import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
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

    return email == storedEmail && hashedPassword == storedPassword;
  } 
  
  bool insertUser(String email, String password) {

    final bytes = utf8.encode(password);
    String hashedPassword = sha256.convert(bytes).toString();
    usersBox.put('email', email);
    usersBox.put('password', hashedPassword);
    
    return true;
  }
}