import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserSession(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', user['username']);
  await prefs.setString('role', user['role']);
}

Future<String?> getUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role'); // Mengembalikan role atau null jika tidak ada

}

Future<String?> getUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username'); // Mengembalikan username atau null jika tidak ada
}