import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de autenticación que consume la API REST.
class AuthService {
  static const _base = 'http://localhost:3000/api';

  // ── Iniciar sesión ────────────────────────────────────────────────────────

  /// Envía credenciales a POST /api/auth/login y guarda el token.
  Future<void> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Error al iniciar sesión');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', body['token'] as String);
    await prefs.setInt('userId', body['userId'] as int);
    await prefs.setString('userName', body['name'] as String);
    await prefs.setString('userEmail', body['email'] as String);
  }

  // ── Registrar cuenta ──────────────────────────────────────────────────────

  /// Envía datos a POST /api/auth/register y guarda el token.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Error al registrar cuenta');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', body['token'] as String);
    await prefs.setInt('userId', body['userId'] as int);
    await prefs.setString('userName', body['name'] as String);
    await prefs.setString('userEmail', body['email'] as String);
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }

  // ── Cambiar contraseña ────────────────────────────────────────────────────

  /// Envía la solicitud a PUT /api/auth/change-password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$_base/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Error al cambiar contraseña');
    }
  }
}
