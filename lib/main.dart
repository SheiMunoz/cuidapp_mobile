import 'package:flutter/material.dart';
import 'screens/abuelo_home.dart'; // Importamos la pantalla que creaste

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuidApp',
      debugShowCheckedModeBanner:
          false, // Saca la cinta roja de "Debug" arriba a la derecha
      theme: ThemeData(useMaterial3: true),
      home:
          const AbueloHome(), // Le decimos que arranque en la pantalla del abuelo
    );
  }
}
