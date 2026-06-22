import 'package:flutter/material.dart';

class CuidAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 1. Definimos que recibe un String común y corriente
  final String titulo;

  const CuidAppBar({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final puedeVolverAtras = Navigator.canPop(context);

    return AppBar(
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      foregroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 150,
      leading: puedeVolverAtras
          ? TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              label: const Text(
                'Volver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
