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
    // Apuntamos directamente al nodo 'perfil' que manda Django
    final perfilNode = (data['perfil'] is Map) ? data['perfil'] : data;

    // Buscamos first_name y last_name exactamente como se llaman en Django
    final firstName = perfilNode['first_name'] ?? '';
    final lastName = perfilNode['last_name'] ?? '';
    final name = '${firstName.toString().trim()} ${lastName.toString().trim()}'
        .trim();

    if (name.isNotEmpty) return name;
    // Si no tiene nombre y apellido cargado, mostramos el username
    return perfilNode['username']?.toString() ?? 'Cuidador';
  }

  Widget _buildDatosList(Map<String, dynamic> data) {
    // Apuntamos directamente al nodo 'perfil'
    final perfilNode = (data['perfil'] is Map) ? data['perfil'] : data;

    // Extraemos el email y el telefono del lugar correcto
    final email = (perfilNode['email'] ?? '').toString();
    final telefono = (perfilNode['telefono'] ?? '').toString();

    // Dejamos dirección por si en algún momento lo sumás a tu modelo
    final direccion = (perfilNode['direccion'] ?? '').toString();

    List<Widget> items = [];

    if (email.trim().isNotEmpty) {
      items.add(_itemDato(Icons.email, 'Email', email.trim()));
    }
    if (telefono.trim().isNotEmpty) {
      items.add(_itemDato(Icons.phone, 'Teléfono', telefono.trim()));
    }
    if (direccion.trim().isNotEmpty) {
      items.add(_itemDato(Icons.location_on, 'Dirección', direccion.trim()));
    }

    if (items.isEmpty) {
      return const Text(
        'No hay datos adicionales cargados.',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }

  // Plantilla visual para cada dato (Ícono + Título + Valor)
  Widget _itemDato(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFF1E88E5), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                          'Información del Perfil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Llamamos a la nueva función que arma la lista de datos
                        _buildDatosList(perfil),
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
