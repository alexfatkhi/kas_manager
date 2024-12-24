import 'package:kas_manager/services/save_user_sessions.dart';
import 'package:flutter/material.dart';
import 'package:kas_manager/services/databaseHelper.dart';

class UserController extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// **Method untuk Login**
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username atau Password tidak boleh kosong.');
      }

      final user = await _databaseHelper.loginUser(username, password);
      if (user != null) {
        await saveUserSession(user);
      }
      if (user == null) {
        _currentUser = null;
        notifyListeners();
        throw Exception('Login gagal, Username atau Password salah.');
      }

      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **Method untuk Register**
  Future<void> register(String username, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (username.isEmpty || password.isEmpty || role.isEmpty) {
        throw Exception('Semua field wajib diisi.');
      }
      if (!['bendahara', 'anggota'].contains(role)) {
        throw Exception('Role tidak valid.');
      }

      await _databaseHelper.registerUser(username, password, role);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **Method untuk Logout**
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
