import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login.dart';

class CuidadorPerfil extends StatefulWidget {
  const CuidadorPerfil({super.key});

  @override
  State<CuidadorPerfil> createState() => _CuidadorPerfilState();
}

class _CuidadorPerfilState extends State<CuidadorPerfil> {
  late final Future<Map<String, dynamic>?> _futurePerfil;

  @override
  void initState() {
    super.initState();
    _futurePerfil = ApiService.getMe();
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que querés salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ApiService.cerrarSesion();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _fullName(Map<String, dynamic> data) {
    if (data['nombre_completo'] != null &&
        data['nombre_completo'].toString().trim().isNotEmpty) {
      return data['nombre_completo'].toString();
    }
    final firstName = data['first_name'] ?? data['nombre'] ?? '';
    final lastName = data['last_name'] ?? data['apellido'] ?? '';
    final name = '${firstName.toString().trim()} ${lastName.toString().trim()}'
        .trim();
    return name.isNotEmpty ? name : 'Cuidador';
  }

  String _contacto(Map<String, dynamic> data) {
    final email = data['email'] ?? data['correo'] ?? '';
    final telefono = data['telefono'] ?? data['phone'] ?? data['celular'] ?? '';
    final direccion = data['direccion'] ?? data['address'] ?? '';

    final lines = <String>[];
    if (email.toString().trim().isNotEmpty) {
      lines.add('Email: ${email.toString().trim()}');
    }
    if (telefono.toString().trim().isNotEmpty) {
      lines.add('Teléfono: ${telefono.toString().trim()}');
    }
    if (direccion.toString().trim().isNotEmpty) {
      lines.add('Dirección: ${direccion.toString().trim()}');
    }
    if (lines.isEmpty) {
      lines.add('Contacto no disponible');
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      appBar: AppBar(
        title: const Text(
          'Perfil del cuidador',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 140, 236),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futurePerfil,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el perfil. Intentá de nuevo.',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          final perfil = snapshot.data;
          if (perfil == null) {
            return const Center(
              child: Text(
                'No se encontró el perfil.',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _fullName(perfil),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Contacto',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _contacto(perfil),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 28),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
