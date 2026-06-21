import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

class ApiService {
  // Emulador: 10.0.2.2, wifi: ip de PC, usb: localhost

  static const String baseUrl = 'http://127.0.0.1:8000';

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
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10)); // ← timeout de 10 segundos

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await guardarTokens(data['access'], data['refresh']);
        return {'ok': true};
      } else {
        return {'ok': false, 'error': 'Usuario o contraseña incorrectos'};
      }
    } catch (e) {
      return {'ok': false, 'error': 'No se pudo conectar al servidor'};
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

  // 1. Obtener el estado del dispositivo del paciente
  static Future<Map<String, dynamic>?> getDispositivoPaciente(
    int pacienteId,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/pacientes/$pacienteId/dispositivo/');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404 || response.statusCode == 403) {
        // Manejar si no hay datos o no tiene permiso
        return null;
      } else {
        throw Exception('Error al cargar dispositivo');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  // 2. Obtener las fotos de mediciones del paciente
  static Future<List<dynamic>> getFotosPaciente(int pacienteId) async {
    final url = Uri.parse('$baseUrl/api/v1/pacientes/$pacienteId/fotos/');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar fotos');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  // 3. Obtener los medicamentos del paciente
  static Future<List<dynamic>> getMedicamentosPaciente(int pacienteId) async {
    final url = Uri.parse(
      '$baseUrl/api/v1/pacientes/$pacienteId/medicamentos/',
    );
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar medicamentos');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  // ── Marcar foto/documento como revisado (lado cuidador) ─────────────

  static Future<Map<String, dynamic>?> marcarFotoRevisada(
    int fotoId, {
    String nota = '',
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/fotos/$fotoId/revisar/');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'nota': nota}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  // ── Eventos del calendario (turnos médicos, etc.) ──────────────────

  static Future<List<dynamic>> getEventos() async {
    final url = Uri.parse('$baseUrl/api/v1/eventos/');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar eventos');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  // ── Notificaciones (campanita) ───────────────────────────────────────

  static Future<List<dynamic>> getNotificaciones() async {
    final url = Uri.parse('$baseUrl/api/v1/notificaciones/');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar notificaciones');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  static Future<bool> marcarNotificacionesLeidas() async {
    final url = Uri.parse('$baseUrl/api/v1/notificaciones/marcar-leidas/');
    try {
      final response = await http.post(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── Chat (mensajería abuelo ↔ cuidador) ─────────────────────────────

  static Future<List<dynamic>> getMensajes(int otroId) async {
    final url = Uri.parse('$baseUrl/api/v1/mensajes/$otroId/');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar mensajes');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> enviarMensaje(
    int otroId,
    String texto,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/mensajes/$otroId/');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'texto': texto}),
      );
      if (response.statusCode == 201) {
        return {'ok': true, 'data': json.decode(response.body)};
      }
      return {'ok': false, 'error': 'No se pudo enviar el mensaje'};
    } catch (e) {
      return {'ok': false, 'error': 'Fallo de conexión: $e'};
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    // 1. Buscamos el token guardado en el celular
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'access_token',
    ); // Usá el nombre con el que lo hayas guardado al hacer login

    // 2. Preparamos la cabecera
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. Si encontramos el token, se lo pegamos a la cabecera
    if (token != null) {
      // La palabra 'Bearer' acompañada del token es el formato estándar que espera Django
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
  // ── Subir foto/documento ───────────────────────────────────────────

  static Future<Map<String, dynamic>> subirFoto({
    required File imagen,
    required String tipo, // 'medicion' | 'receta' | 'indicacion' | 'otro'
    String notaPaciente = '',
  }) async {
    final token = await getAccessToken();
    if (token == null) return {'ok': false, 'error': 'No hay sesión activa'};

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/documentos/subir/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['tipo'] = tipo;
      if (notaPaciente.isNotEmpty) {
        request.fields['nota_paciente'] = notaPaciente;
      }
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'ok': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'ok': false,
          'error': 'No se pudo subir el documento (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'ok': false, 'error': 'Fallo de conexión: $e'};
    }
  }
}
