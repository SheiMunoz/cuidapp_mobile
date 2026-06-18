import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class DeviceService {
  static final Battery _battery = Battery();

  // ── Batería ────────────────────────────────────────────────────────
  static Future<int> getBateria() async {
    return await _battery.batteryLevel;
  }

  // ── Tipo de conexión ───────────────────────────────────────────────
  static Future<String> getConexion() async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) return 'wifi';
    if (result.contains(ConnectivityResult.mobile)) return 'datos_moviles';
    if (result.contains(ConnectivityResult.ethernet)) return 'ethernet';
    return 'sin_conexion';
  }

  // ── Localización ───────────────────────────────────────────────────
  static Future<Map<String, double?>?> getUbicacion() async {
    final permiso = await Permission.location.request();
    if (!permiso.isGranted) return null;

    final habilitado = await Geolocator.isLocationServiceEnabled();
    if (!habilitado) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return {'latitud': pos.latitude, 'longitud': pos.longitude};
    } catch (_) {
      return null;
    }
  }

  // ── Enviar todo al servidor ────────────────────────────────────────
  static Future<bool> enviarDatos() async {
    final bateria = await getBateria();
    final conexion = await getConexion();
    final ubicacion = await getUbicacion();

    return ApiService.enviarDatoDispositivo({
      'bateria': bateria,
      'tipo_conexion': conexion,
      'latitud': ubicacion?['latitud'],
      'longitud': ubicacion?['longitud'],
    });
  }
}
