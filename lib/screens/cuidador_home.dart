import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cuidador_perfil.dart';
import 'abuelo_detalle.dart';
import 'chat_screen.dart';
import 'campanita_notificaciones.dart';

class CuidadorHome extends StatefulWidget {
  const CuidadorHome({super.key});

  @override
  State<CuidadorHome> createState() => _CuidadorHomeState();
}

class _CuidadorHomeState extends State<CuidadorHome> {
  Future<List<dynamic>?>? _futureAbuelos;
  String _nombreCuidador = 'Cuidador';

  @override
  void initState() {
    super.initState();
    _cargarAbuelos();
    _cargarNombreCuidador();
  }

  void _cargarAbuelos() {
    setState(() {
      _futureAbuelos = ApiService.getAbuelosACargo();
    });
  }

  Future<void> _cargarNombreCuidador() async {
    final me = await ApiService.getMe();
    if (!mounted || me == null) return;

    final perfil = me['perfil'] ?? me;
    final nombre =
        perfil['nombre'] ??
        perfil['first_name'] ??
        perfil['username'] ??
        perfil['user']?['username'];

    if (nombre != null && nombre.toString().trim().isNotEmpty) {
      setState(() {
        _nombreCuidador = nombre.toString();
      });
    }
  }

  String _nombreDeAbuelo(Map<String, dynamic> abuelo) {
    final user = abuelo['user'] as Map<String, dynamic>?;

    final firstName = user?['first_name']?.toString().trim() ?? '';
    final lastName = user?['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;

    final username = user?['username']?.toString().trim();
    if (username != null && username.isNotEmpty) return username;

    return 'Abuelo sin nombre';
  }

  bool _tieneMensajeNuevo(Map<String, dynamic> abuelo) {
    return abuelo['tiene_mensaje_no_leido'] == true;
  }

  String _detalleDeAbuelo(Map<String, dynamic> abuelo) {
    final edad = abuelo['edad'] != null ? 'Edad ${abuelo['edad']}' : '';
    final condicion =
        abuelo['condicion'] ?? abuelo['diagnostico'] ?? abuelo['detalle'] ?? '';
    final parts = [
      edad,
      condicion.toString().trim(),
    ].where((value) => value.isNotEmpty).toList();
    return parts.isEmpty ? 'Detalle no disponible' : parts.join(' · ');
  }

  Future<void> _abrirChat(int pacienteId, String nombreAbuelo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(otroId: pacienteId, nombreOtro: nombreAbuelo),
      ),
    );
    // Al volver del chat, los mensajes ya se marcaron como leídos en el
    // backend. Recargamos la lista para que el badge "Mensaje nuevo"
    // desaparezca.
    _cargarAbuelos();
  }

  Future<void> _abrirDetalle(
    int pacienteId,
    String nombreAbuelo,
    Map<String, dynamic> abuelo,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AbueloDetalle(
          pacienteId: pacienteId,
          nombre: nombreAbuelo,
          perfil: abuelo,
        ),
      ),
    );
    _cargarAbuelos();
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
                            'Hola $_nombreCuidador!',
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const CampanitaNotificaciones(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Abuelos a cargo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _cargarAbuelos(),
                  child: FutureBuilder<List<dynamic>?>(
                    future: _futureAbuelos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar los abuelos. Intentá de nuevo.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final abuelos = snapshot.data;
                      if (abuelos == null || abuelos.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay abuelos asignados todavía.',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: abuelos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final abuelo = Map<String, dynamic>.from(
                            abuelos[index] as Map,
                          );
                          final mensajeNuevo = _tieneMensajeNuevo(abuelo);
                          final pacienteId = abuelo['user']?['id'];
                          final nombreAbuelo = _nombreDeAbuelo(abuelo);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              title: Text(
                                nombreAbuelo,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: mensajeNuevo
                                  ? const Row(
                                      children: [
                                        Icon(
                                          Icons.mark_chat_unread,
                                          size: 16,
                                          color: Color(0xFF1E88E5),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Mensaje nuevo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'No hay mensajes nuevos',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      mensajeNuevo
                                          ? Icons.mark_chat_unread
                                          : Icons.chat_bubble_outline,
                                      color: const Color(0xFF1E88E5),
                                    ),
                                    onPressed: pacienteId == null
                                        ? null
                                        : () => _abrirChat(
                                            pacienteId,
                                            nombreAbuelo,
                                          ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                if (pacienteId == null) return;
                                _abrirDetalle(pacienteId, nombreAbuelo, abuelo);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.person, size: 28),
                label: const Text(
                  'Ir a mi perfil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuidadorPerfil(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
