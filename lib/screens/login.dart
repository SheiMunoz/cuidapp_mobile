import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'abuelo_home.dart';
import 'cuidador_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final resultado = await ApiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!resultado['ok']) {
      setState(() {
        _error = resultado['error'];
        _cargando = false;
      });
      return;
    }

    // Chequeamos el rol
    final me = await ApiService.getMe();

    if (!mounted) return;

    if (me == null) {
      setState(() {
        _error = 'No se pudo obtener el perfil. Intentá de nuevo.';
        _cargando = false;
      });
      return;
    }

    final rol = me['rol'];

    if (rol == 'paciente') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AbueloHome()),
      );
    } else if (rol == 'cuidador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CuidadorHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 201, 238),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo texto grande.png', height: 300),
              const SizedBox(height: 40),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator()
                      : const Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
