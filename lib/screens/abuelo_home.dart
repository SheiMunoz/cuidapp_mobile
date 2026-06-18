import 'package:flutter/material.dart';
import 'abuelo_perfil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AbueloHome extends StatelessWidget {
  const AbueloHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      body: SafeArea(
        child: Padding(
          // Márgenes laterales para que los botones no toquen los bordes
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Logo
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  // 👈 1. Cambiamos el hijo directo por una Fila
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Alinea el texto al centro vertical del logo
                  children: [
                    // Tu logo original
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140,
                      width: 140,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(
                      width: 12,
                    ), // 👈 2. Espacio horizontal entre el logo y el texto
                    // 👈 3. Usamos 'Expanded' para que el texto ocupe el resto del ancho sin romperse
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea el texto a la izquierda
                        mainAxisSize: MainAxisSize
                            .min, // Hace que la columna ocupe solo el espacio necesario
                        children: [
                          Text(
                            'Cuida App',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Queda genial sobre tu fondo azul
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hola! *Usuario*',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50), // Espacio entre el logo y los botones
              // 2. Grid de 2 columnas x 3 filas
              Expanded(
                child: Column(
                  children: [
                    // Fila 1
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Perfil',
                              backgroundColor: const Color(0xFF1E88E5), // Azul
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/perfil.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AbueloPerfil(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Subir Imagen',
                              backgroundColor: const Color(0xFF43A047), // Verde
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/pics.png',
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fila 2
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Medicamentos',
                              backgroundColor: const Color(
                                0xFFFFB300,
                              ), // Amarillo/Naranja
                              textColor: Colors.black87,
                              iconPath: 'assets/images/buttons/medicamento.png',
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMenuButton(
                              text: 'Localización',
                              backgroundColor: const Color(
                                0xFF546E7A,
                              ), // Gris oscuro
                              textColor: Colors.white,
                              iconPath: 'assets/images/buttons/gps.png',
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEmergencyButton(
                            text: 'Emergencia',
                            backgroundColor: const Color(
                              0xFFE53935,
                            ), // Rojo para alertas
                            textColor: Colors.white,
                            iconPath: 'assets/images/buttons/heart.png',
                            onPressed: () {
                              // Lógica del botón
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 68),
        padding: const EdgeInsets.symmetric(vertical: 22), // Altura del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
        ),
        elevation: 2, // Sombra ligera
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 90, width: 90),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 400,
      width: 400,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 90, width: 90),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
