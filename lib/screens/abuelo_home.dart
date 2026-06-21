import 'package:flutter/material.dart';
import 'abuelo_perfil.dart';
import 'abuelo_medicamento.dart';
import 'package:cuidapp_mobile/services/api_service.dart';
import 'package:cuidapp_mobile/services/device_service.dart';
import 'abuelo_subir_documento.dart';
import 'package:url_launcher/url_launcher.dart';
import 'turnos_abuelo.dart';
import 'campanita_notificaciones.dart';

class AbueloHome extends StatefulWidget {
  const AbueloHome({super.key});

  @override
  State<AbueloHome> createState() => _AbueloHomeState();
}

class _AbueloHomeState extends State<AbueloHome> {
  String _nombreAbuelo = "..."; // Texto temporal mientras carga
  String? _telefonoEmergencia;

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final me = await ApiService.getMe();
    if (mounted) {
      setState(() {
        if (me != null && me['perfil'] != null) {
          final username =
              me['perfil']['user']?['username'] ??
              me['perfil']['username'] ??
              'Usuario';
          _nombreAbuelo = username.toString();
          final List<dynamic> tutores = me['perfil']['tutores_info'] ?? [];
          final emergencia = tutores.firstWhere(
            (t) => t['es_emergencia'] == true,
            orElse: () => null,
          );
          if (emergencia != null &&
              emergencia['telefono'].toString().isNotEmpty) {
            _telefonoEmergencia = emergencia['telefono'];
          }
        } else {
          _nombreAbuelo = "Usuario";
        }
      });
    }
  }

  Future<void> _llamarEmergencia() async {
    if (_telefonoEmergencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un cuidador de emergencia configurado'),
        ),
      );
      return;
    }
    final uri = Uri.parse('tel:$_telefonoEmergencia');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Logo y Saludo
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140,
                      width: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Cuida App',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hola $_nombreAbuelo!',
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            // Esto evita que si el nombre es muy largo, rompa la pantalla
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const CampanitaNotificaciones(),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // 2. Grid de 2 columnas x 3 filas
              Expanded(
                child: Column(
                  children: [
                    // Fila 1
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Perfil',
                              backgroundColor: const Color(0xFF1E88E5),
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/perfil.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AbueloPerfil(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Subir Imagen',
                              backgroundColor: const Color(0xFF43A047),
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/pics.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AbueloSubirDocumento(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fila 2
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Medicamentos',
                              backgroundColor: const Color(0xFFFFB300),
                              textColor: Colors.black87,
                              iconPath: 'assets/images/buttons/medicamento.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AbueloMedicamentos(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMenuButton(
                              text:
                                  'Turnos\nMédicos', // El \n lo pone en dos líneas para que no quede gigante
                              backgroundColor: const Color(
                                0xFF009688,
                              ), // Verde teal
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/calendario.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // ¡Llamamos a la pantalla nueva!
                                    builder: (context) =>
                                        const TurnosAbueloScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fila 3
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEmergencyButton(
                            text: 'Emergencia',
                            backgroundColor: const Color(0xFFE53935),
                            textColor: Colors.white,
                            iconPath: 'assets/images/buttons/heart.png',
                            onPressed: _llamarEmergencia,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 68),
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      onPressed: () {
        DeviceService.enviarDatos();
        onPressed();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 90, width: 90),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 400,
      width: 400,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 90, width: 90),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
