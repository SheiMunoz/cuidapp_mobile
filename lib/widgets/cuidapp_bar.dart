import 'package:flutter/material.dart';

class CuidAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 1. Definimos que recibe un String común y corriente
  final String titulo; 

  const CuidAppBar({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final puedeVolverAtras = Navigator.canPop(context);

    return AppBar(
      title: Text(
        titulo,
        style: const TextStyle(fontWeight: FontWeight.bold), // Texto en Negrita
      ),
      backgroundColor: const Color.fromARGB(255, 43, 140, 236), // Tu azul exacto
      foregroundColor: Colors.white, // Íconos y letras en blanco
      centerTitle: true, // Título centrado
      automaticallyImplyLeading: false, 
      leadingWidth: 150, 
      leading: puedeVolverAtras 
          ? TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              label: const Text(
                'Volver',
                style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
              ),
            )
          : null, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}