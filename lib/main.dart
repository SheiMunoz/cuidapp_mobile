import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/abuelo_home.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuidApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final token = await ApiService.getAccessToken();

    if (!mounted) return;

    if (token != null) {
      final me = await ApiService.getMe();
      if (!mounted) return;

      if (me != null) {
        // Token válido → va directo al home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AbueloHome()),
        );
        return;
      }
    }

    // Sin token o token vencido → va a login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga mientras verifica
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
