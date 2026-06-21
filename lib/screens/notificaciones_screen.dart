import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/services/api_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarYMarcarLeidas();
  }

  Future<void> _cargarYMarcarLeidas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await ApiService.getNotificaciones();
      if (!mounted) return;
      setState(() {
        _notificaciones = data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _cargando = false;
      });
      // Las marcamos como leídas una vez que el usuario ya las vio en pantalla.
      if (_notificaciones.isNotEmpty) {
        await ApiService.marcarNotificacionesLeidas();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las notificaciones.';
        _cargando = false;
      });
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'medicacion':
        return Icons.medication;
      case 'evento':
        return Icons.calendar_today;
      case 'mensaje':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'medicacion':
        return const Color(0xFFFFB300);
      case 'evento':
        return const Color(0xFF009688);
      case 'mensaje':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF757575);
    }
  }

  String _formatearFecha(String fechaIso) {
    final fecha = DateTime.parse(fechaIso).toLocal();
    final ahora = DateTime.now();
    final esHoy =
        fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    if (esHoy) return 'Hoy a las $hora';
    return '${fecha.day}/${fecha.month} a las $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cargarYMarcarLeidas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _notificaciones.isEmpty
          ? const Center(
              child: Text(
                'No tenés notificaciones nuevas.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarYMarcarLeidas,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _notificaciones.length,
                itemBuilder: (context, index) {
                  final n = _notificaciones[index];
                  final tipo = (n['tipo'] ?? '').toString();
                  final color = _colorPorTipo(tipo);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(_iconoPorTipo(tipo), color: Colors.white),
                      ),
                      title: Text(
                        (n['titulo'] ?? '').toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((n['mensaje'] ?? '').toString()),
                          const SizedBox(height: 4),
                          Text(
                            _formatearFecha(n['fecha_creacion'].toString()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
