import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Future<void> _abrirChat(int pacienteId, String nombreAbuelo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(otroId: pacienteId, nombreOtro: nombreAbuelo),
      ),
    );
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
          // ✅ Padding responsive
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
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
                      height: 100.sp, // ✅ Logo responsive
                      width: 100.sp,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 10.w), // ✅ Espacio responsive
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cuida App',
                            style: TextStyle(
                              fontSize: 32.sp, // ✅ Texto responsive
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h), // ✅ Espacio responsive
                          Text(
                            'Hola $_nombreCuidador!',
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
              SizedBox(height: 24.h), // ✅ Espacio responsive
              Text(
                'Abuelos a cargo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp, // ✅ Texto responsive
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h), // ✅ Espacio responsive
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _cargarAbuelos(),
                  child: FutureBuilder<List<dynamic>?>(
                    future: _futureAbuelos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3.w, // ✅ Grosor responsive
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar los abuelos. Intentá de nuevo.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp, // ✅ Texto responsive
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final abuelos = snapshot.data;
                      if (abuelos == null || abuelos.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay abuelos asignados todavía.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp, // ✅ Texto responsive
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: abuelos.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
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
                              borderRadius: BorderRadius.circular(
                                14.r,
                              ), // ✅ Radio responsive
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r, // ✅ Sombra responsive
                                  offset: Offset(0, 3.h), // ✅ Offset responsive
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, // ✅ Padding responsive
                                vertical: 12.h,
                              ),
                              title: Text(
                                nombreAbuelo,
                                style: TextStyle(
                                  fontSize: 18.sp, // ✅ Texto responsive
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: mensajeNuevo
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.mark_chat_unread,
                                          size: 14.sp, // ✅ Icono responsive
                                          color: const Color(0xFF1E88E5),
                                        ),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            'Mensaje nuevo',
                                            style: TextStyle(
                                              fontSize:
                                                  14.sp, // ✅ Texto responsive
                                              color: const Color(0xFF1E88E5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'No hay mensajes nuevos',
                                      style: TextStyle(
                                        fontSize: 14.sp, // ✅ Texto responsive
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
                                      size: 22.sp, // ✅ Icono responsive
                                    ),
                                    onPressed: pacienteId == null
                                        ? null
                                        : () => _abrirChat(
                                            pacienteId,
                                            nombreAbuelo,
                                          ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 22.sp, // ✅ Icono responsive
                                  ),
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
              SizedBox(height: 20.h), // ✅ Espacio responsive
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h), // ✅ Alto responsive
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ), // ✅ Radio responsive
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                  ), // ✅ Padding responsive
                ),
                icon: Icon(Icons.person, size: 24.sp), // ✅ Icono responsive
                label: Text(
                  'Ir a mi perfil',
                  style: TextStyle(
                    fontSize: 18.sp, // ✅ Texto responsive
                    fontWeight: FontWeight.bold,
                  ),
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
