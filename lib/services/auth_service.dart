import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Thrown when a sign-in or sign-up cannot be completed.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  static const _usersKey = 'users';
  static const _sessionKey = 'session_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return Future.value(<String, dynamic>{});
    return Future.value(jsonDecode(raw) as Map<String, dynamic>);
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  String _newSalt() {
    final rng = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rng.nextInt(256)));
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String address,
    required AccountType accountType,
  }) async {
    final prefs = await _prefs;
    final users = await _readUsers(prefs);
    final key = email.trim().toLowerCase();

    if (users.containsKey(key)) {
      throw AuthException('An account with this email already exists');
    }

    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      email: key,
      phone: phone.trim(),
      address: address.trim(),
      accountType: accountType,
    );

    final salt = _newSalt();
    users[key] = {
      ...user.toMap(),
      'salt': salt,
      'passwordHash': _hash(password, salt),
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_sessionKey, key);
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    final prefs = await _prefs;
    final users = await _readUsers(prefs);
    final key = email.trim().toLowerCase();
    final record = users[key] as Map<String, dynamic>?;

    const wrong = 'Incorrect email or password';
    if (record == null) throw AuthException(wrong);
    if (_hash(password, record['salt'] as String) != record['passwordHash']) {
      throw AuthException(wrong);
    }

    await prefs.setString(_sessionKey, key);
    return UserModel.fromMap(record);
  }

  /// The signed-in user, or null if nobody is signed in.
  Future<UserModel?> currentUser() async {
    final prefs = await _prefs;
    final key = prefs.getString(_sessionKey);
    if (key == null) return null;
    final users = await _readUsers(prefs);
    final record = users[key] as Map<String, dynamic>?;
    if (record == null) return null;
    return UserModel.fromMap(record);
  }

  Future<void> logout() async => (await _prefs).remove(_sessionKey);

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await _prefs;
    final users = await _readUsers(prefs);
    final key = email.trim().toLowerCase();
    final record = users[key] as Map<String, dynamic>?;

    const wrong = 'Current password is incorrect';
    if (record == null) throw AuthException(wrong);
    if (_hash(currentPassword, record['salt'] as String) !=
        record['passwordHash']) {
      throw AuthException(wrong);
    }

    final salt = _newSalt();
    users[key] = {
      ...record,
      'salt': salt,
      'passwordHash': _hash(newPassword, salt),
    };

    await prefs.setString(_usersKey, jsonEncode(users));
  }
}
