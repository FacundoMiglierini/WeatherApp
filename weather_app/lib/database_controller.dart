import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {

  var usersBox = Hive.box<String>('user');
  
  bool isValidUser(String email, String password) {

    var storedEmail = usersBox.get('email');
    var storedPassword = usersBox.get('password');
    
    if (storedEmail == null || storedPassword == null) {
      return false;
    } 
    
    return email == storedEmail && password == storedPassword;
  } 
  
  void insertUser(String email, String password) {
    usersBox.put('email', email);
    usersBox.put('password', password);
  }
}