import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ATENCIÓN: Si vas a probar en el Motorola Edge físico,
  // cambiá localhost por la IP de tu compu (ej: http://192.168.1.50:8000)
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

  // ── Medicamentos ───────────────────────────────────────────────────

  static Future<List<dynamic>?> getMedicamentos() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/medicamentos/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ── Registrar Toma de Medicamento ──────────────────────────────────

  static Future<Map<String, dynamic>> registrarToma(int medicamentoId) async {
    final token = await getAccessToken();
    if (token == null) return {'ok': false, 'error': 'No hay sesión activa'};

    final response = await http.post(
      Uri.parse('$baseUrl/api/medicamentos/$medicamentoId/registrar-toma/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return {'ok': true};
    } else {
      final body = jsonDecode(response.body);
      return {'ok': false, 'error': body['mensaje'] ?? 'Error desconocido'};
    }
  }

  // ── Datos del dispositivo ──────────────────────────────────────────

  static Future<bool> enviarDatoDispositivo(Map<String, dynamic> datos) async {
    final token = await getAccessToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/dispositivo/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(datos),
    );
    return response.statusCode == 201;
  }
  // ── Cuidadores: Abuelos a cargo ────────────────────────────────────

  static Future<List<dynamic>?> getAbuelosACargo() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/pacientes/',
      ), // 👈 Acá conectamos con el nuevo path
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
} // <-- ¡Esta es la llave maestra que envuelve todo!
