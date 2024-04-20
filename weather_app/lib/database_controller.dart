import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypt/crypt.dart';


class DatabaseHelper {

  var usersBox = Hive.box<String>('user');
  
  bool isValidUser(String email, String password) {

    var storedEmail = usersBox.get('email');
    var storedPassword = usersBox.get('password');
    
    if (storedEmail == null || storedPassword == null) {
      return false;
    } 
    
    String hashedPassword = Crypt.sha256(password).toString();
    
    return email == storedEmail && hashedPassword == storedPassword;
  } 
  
  bool insertUser(String email, String password) {
    String hashedPassword = Crypt.sha256(password).toString();
    usersBox.put('email', email);
    usersBox.put('password', hashedPassword);
    
    return true;
  }
}