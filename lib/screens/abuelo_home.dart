import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          // ✅ Padding responsive
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
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
                      height: 50.sp, // ✅ Logo responsive
                      width: 50.sp,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w), // ✅ Espacio responsive
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cuida App',
                            style: TextStyle(
                              fontSize: 30.sp, // ✅ Texto responsive
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h), // ✅ Espacio responsive
                          Text(
                            'Hola $_nombreAbuelo!',
                            style: TextStyle(
                              fontSize: 24.sp, // ✅ Texto responsive
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const CampanitaNotificaciones(),
                  ],
                ),
              ),
              SizedBox(height: 30.h), // ✅ Espacio responsive
              // Menú de botones
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
                          SizedBox(width: 12.w), // ✅ Espacio responsive
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
                    SizedBox(height: 12.h), // ✅ Espacio responsive
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
                          SizedBox(width: 12.w), // ✅ Espacio responsive
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Turnos\nMédicos',
                              backgroundColor: const Color(0xFF009688),
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/calendario.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
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
                    SizedBox(height: 12.h), // ✅ Espacio responsive
                    // Fila 3 - Botón de emergencia
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
        minimumSize: Size(double.infinity, 60.h), // ✅ Alto responsive
        padding: EdgeInsets.symmetric(vertical: 14.h), // ✅ Padding responsive
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r), // ✅ Radio responsive
        ),
        elevation: 2,
      ),
      onPressed: () {
        DeviceService.enviarDatos();
        onPressed();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 40.sp, // ✅ Icono responsive
            width: 40.sp,
          ),
          SizedBox(height: 6.h), // ✅ Espacio responsive
          Text(
            text,
            style: TextStyle(
              fontSize: 20.sp, // ✅ Texto responsive
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
      height: 150.sp, // ✅ Tamaño responsive
      width: 150.sp, // ✅ Tamaño responsive
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
          padding: EdgeInsets.all(20.sp), // ✅ Padding responsive
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 40.sp, // ✅ Icono responsive
              width: 40.sp,
            ),
            SizedBox(height: 8.h), // ✅ Espacio responsive
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 22.sp, // ✅ Texto responsive
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
