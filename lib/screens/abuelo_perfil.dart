import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cuidapp_mobile/widgets/cuidapp_bar.dart';
import 'package:cuidapp_mobile/services/api_service.dart';
import 'abuelo_medicamento.dart';
import 'login.dart';

class AbueloPerfil extends StatefulWidget {
  const AbueloPerfil({super.key});

  @override
  State<AbueloPerfil> createState() => _AbueloPerfilState();
}

class _AbueloPerfilState extends State<AbueloPerfil> {
  String _tipoMedicion = "";

  // agregando datos de la API
  bool _cargando = true;
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  // ── Llamada a la API ───────────────────────────────────────────────
  Future<void> _cargarDatosPerfil() async {
    final me = await ApiService.getMe();
    if (mounted) {
      setState(() {
        _perfil = me?['perfil'];
        _cargando = false;
      });
    }
  }

  // ── Cámara ─────────────────────────────────────────────────────────
  void _abrirCamarayEnviar() async {
    final ImagePicker selector = ImagePicker();
    final XFile? fotoMedicion = await selector.pickImage(
      source: ImageSource.camera,
    );

    if (fotoMedicion != null) {
      print('¡Foto de $_tipoMedicion tomada!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de $_tipoMedicion enviada con éxito')),
      );
    }
  } // ← _abrirCamarayEnviar cierra acá

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 140, 236),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _construirPerfil(),
    );
  }

  Widget _construirPerfil() {
    // Extraemos datos con valores por defecto por si vienen nulos
    final obraSocial = _perfil?['obra_social']?.toString().isNotEmpty == true
        ? _perfil!['obra_social']
        : 'No registrada';
    final numAfiliado =
        _perfil?['numero_afiliado']?.toString().isNotEmpty == true
        ? _perfil!['numero_afiliado']
        : 'No registrado';
    final grupoSanguineo =
        _perfil?['grupo_sanguineo']?.toString().isNotEmpty == true
        ? _perfil!['grupo_sanguineo']
        : 'No registrado';

    // Chequeamos qué mediciones requiere
    final requierePresion = _perfil?['requiere_control_presion'] == true;
    final requiereGlucosa = _perfil?['requiere_control_glucosa'] == true;
    final requierePeso = _perfil?['requiere_control_peso'] == true;

    // Armamos la lista dinámica de botones
    List<Widget> botonesControl = [];
    if (requierePresion)
      botonesControl.add(
        _buildControlBtn(
          titulo: 'Presión',
          icon: Icons.favorite,
          color: Colors.red,
        ),
      );
    if (requiereGlucosa)
      botonesControl.add(
        _buildControlBtn(
          titulo: 'Glucosa',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
      );
    if (requierePeso)
      botonesControl.add(
        _buildControlBtn(
          titulo: 'Peso',
          icon: Icons.monitor_weight,
          color: Colors.orange,
        ),
      );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Obra Social: $obraSocial',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'N° Afiliado: $numAfiliado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // 👈 Nueva fila de Grupo Sanguíneo
              'Grupo Sanguíneo: $grupoSanguineo',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 68),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.medication, size: 30),
              label: const Text(
                'Mis medicamentos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AbueloMedicamentos(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            if (botonesControl.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Controles médicos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                            botonesControl, // 👈 Solo dibuja los que necesita
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required String titulo,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            shape: const CircleBorder(),
            fixedSize: const Size(65, 65),
            elevation: 0,
          ),
          onPressed: () {
            setState(() => _tipoMedicion = titulo.toLowerCase());
            _abrirCamarayEnviar();
          },
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
