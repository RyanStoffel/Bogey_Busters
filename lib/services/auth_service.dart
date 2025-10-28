import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'all_users';
  final _uuid = const Uuid();

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<User?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return null;

    final users = (jsonDecode(usersJson) as List)
        .map((u) => User.fromJson(u))
        .toList();

    // Simple email/password check (in production, use proper authentication)
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );

    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<User> signup(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users
    final usersJson = prefs.getString(_usersKey);
    final users = usersJson != null
        ? (jsonDecode(usersJson) as List).map((u) => User.fromJson(u)).toList()
        : <User>[];

    // Check if user already exists
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('User already exists');
    }

    // Create new user
    final newUser = User(
      id: _uuid.v4(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    users.add(newUser);

    // Save users and set current user
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    await prefs.setString(_userKey, jsonEncode(newUser.toJson()));

    return newUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Update current user
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    // Update in users list
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = (jsonDecode(usersJson) as List)
          .map((u) => User.fromJson(u))
          .toList();

      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
        await prefs.setString(
          _usersKey,
          jsonEncode(users.map((u) => u.toJson()).toList()),
        );
      }
    }
  }
}
