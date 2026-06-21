import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/services/api_service.dart';
import 'notificaciones_screen.dart';

class CampanitaNotificaciones extends StatefulWidget {
  final Color color;

  const CampanitaNotificaciones({super.key, this.color = Colors.white});

  @override
  State<CampanitaNotificaciones> createState() =>
      _CampanitaNotificacionesState();
}

class _CampanitaNotificacionesState extends State<CampanitaNotificaciones> {
  int _cantidad = 0;

  @override
  void initState() {
    super.initState();
    _cargarCantidad();
  }

  Future<void> _cargarCantidad() async {
    try {
      final notificaciones = await ApiService.getNotificaciones();
      if (!mounted) return;
      setState(() => _cantidad = notificaciones.length);
    } catch (_) {
      // Si falla, simplemente no mostramos el contador.
    }
  }

  Future<void> _abrirNotificaciones() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
    );
    // Al volver, ya se marcaron como leídas; refrescamos el contador.
    _cargarCantidad();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: widget.color, size: 30),
          onPressed: _abrirNotificaciones,
        ),
        if (_cantidad > 0)
          Positioned(
            right: 10,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _cantidad > 9 ? '9+' : '$_cantidad',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
