import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }


class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _busy = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get busy => _busy;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  
  Future<void> loadSession() async {
    _user = await _service.currentUser();
    _status =
        _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

 
  Future<String?> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String address,
    required AccountType accountType,
  }) =>
      _run(() => _service.register(
            fullName: fullName,
            email: email,
            phone: phone,
            password: password,
            address: address,
            accountType: accountType,
          ));

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return 'You must be signed in to change your password.';

    _busy = true;
    notifyListeners();
    try {
      await _service.changePassword(
        email: _user!.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<String?> _run(Future<UserModel> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      _user = await action();
      _status = AuthStatus.authenticated;
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
