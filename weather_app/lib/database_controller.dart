import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, email TEXT UNIQUE, password TEXT)',
        );
      },
        
      version: 1,
    );
  }


  Future<void> insertUser(User user) async {

    final db = await database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<User> user(String email, String password) async {

    final db = await database;

    final List<Map<String, Object?>> userMap = await db.query(
      'users', 
      where: 'email = $email and password = $password',
      limit: 1,
    );
    if (userMap.isNotEmpty) {
      return User.fromMap(userMap.first);
    } else {
      throw Exception('Wrong login credentials.');
    }
  }
  
  //TODO retrieve emails only
  Future<List<User>> users() async {

    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('users');

    return [
      for (final {
            'id': id as int,
            'email': email as String,
            'password': password as String,
          } in dogMaps)
        User(id: id, email: email, password: password),
    ];
  }
}

class User { 
  final int id;
  final String email;
  final String password;
  
  const User({
    required this.id,
    required this.email,
    required this.password,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password}';
  }
}