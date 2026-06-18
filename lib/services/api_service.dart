import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Emulador Android → 10.0.2.2  |  Teléfono físico → IP de la PC | Teléfono por USB localhost
  static const String baseUrl = 'http://localhost:8000';

  // ── Guardar y leer tokens ──────────────────────────────────────────

  static Future<void> guardarTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ── Login ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await guardarTokens(data['access'], data['refresh']);
      return {'ok': true};
    } else {
      return {'ok': false, 'error': 'Usuario o contraseña incorrectos'};
    }
  }

  // ── Perfil del usuario autenticado ────────────────────────────────

  static Future<Map<String, dynamic>?> getMe() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/me/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
