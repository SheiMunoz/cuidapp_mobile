import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/services/api_service.dart';
import 'abuelo_medicamento.dart';
import 'login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_screen.dart';

class AbueloPerfil extends StatefulWidget {
  const AbueloPerfil({super.key});

  @override
  State<AbueloPerfil> createState() => _AbueloPerfilState();
}

class _AbueloPerfilState extends State<AbueloPerfil> {
  bool _cargando = true;
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  // ── Llamo a la API
  Future<void> _cargarDatosPerfil() async {
    final me = await ApiService.getMe();
    if (mounted) {
      setState(() {
        _perfil = me?['perfil'];
        _cargando = false;
      });
    }
  }

  // ── Cerrar sesión (escondido para que el abuelo no toque sin querer)
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
    // Datos con valores por defecto
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

    // Lista dinámica de botones
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
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
                            botonesControl, // Solo las mediciones que necesita
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _buildListaCuidadores(),
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
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar la llamada')),
        );
      }
    }
  }

  void _abrirChat(int cuidadorId, String nombreCuidador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(otroId: cuidadorId, nombreOtro: nombreCuidador),
      ),
    );
  }

  Widget _buildListaCuidadores() {
    final List<dynamic> tutores = _perfil?['tutores_info'] ?? [];

    if (tutores.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mis cuidadores',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...tutores.map((t) {
              final esEmergencia = t['es_emergencia'] == true;
              final telefono = (t['telefono'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: esEmergencia
                      ? Border.all(color: Colors.red, width: 2.5)
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: esEmergencia
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      child: Icon(
                        Icons.person,
                        color: esEmergencia ? Colors.red : Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['nombre'] ?? '',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            t['parentesco']?.toString().isNotEmpty == true
                                ? t['parentesco']
                                : 'Cuidador',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          if (esEmergencia)
                            const Text(
                              'Contacto de emergencia',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (telefono.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _llamar(telefono),
                      ),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.blue),
                      onPressed: () => _abrirChat(
                        t['id'] as int,
                        (t['nombre'] ?? 'Cuidador').toString(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
