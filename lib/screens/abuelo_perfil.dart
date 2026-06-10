import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/widgets/cuidapp_bar.dart';

class AbueloPerfil extends StatefulWidget {
  const AbueloPerfil({super.key});

  @override
  State<AbueloPerfil> createState() => _AbueloPerfilState();
}

class _AbueloPerfilState extends State<AbueloPerfil> {
  String _tipoMedicion = "";

  void _abrirCamarayEnviar() async {
    final ImagePicker selector = ImagePicker();
    final XFile? fotoMedicion = await selector.pickImage(
      source: ImageSource.camera,
    );

    if (fotoMedicion != null) {
      print('¡Foto de $_tipoMedicion tomada!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto de $_tipoMedicion enviada con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),

      // Barra superior con el título
      appBar: AppBar(
        // 3. Cambiamos fontweight a fontWeight (con W mayúscula)
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 140, 236),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // Cuerpo de la pantalla con los botones
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50, // Tamaño de la foto
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ), // Foto temporal
                ),
              ),
              const SizedBox(height: 16),

              // Pendiente conexión con API
              const Text(
                'Nombre: *Usuario*',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Obra Social: *Obra Social*',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Número de afiliado: *Número de afiliado*',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Boton
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5), // Azul
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 68),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.medication, size: 30),
                label: const Text(
                  'Mis medicamentos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                // Pasar a otra ventana
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AbueloMedicamentos(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Seccion de controles médicos
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Controles médicos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlBtn(
                            titulo: 'Presión',
                            icon: Icons.favorite,
                            color: Colors.red,
                          ),
                          _buildControlBtn(
                            titulo: 'Glucosa',
                            icon: Icons.water_drop,
                            color: Colors.blue,
                          ),
                          _buildControlBtn(
                            titulo: 'Peso',
                            icon: Icons.monitor_weight,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funcionamiento general de los botones
  Widget _buildControlBtn({
    required String titulo,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            shape: const CircleBorder(),
            fixedSize: const Size(65, 65),
            elevation: 0,
          ),
          onPressed: () {
            setState(() {
              _tipoMedicion = titulo.toLowerCase();
            });
            _abrirCamarayEnviar();
          },
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// PLACEHOLDER PARA LA LISTA DE MEDICAMENTOS
class AbueloMedicamentos extends StatelessWidget {
  const AbueloMedicamentos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis medicamentos')),
      body: const Center(child: Text('Para traer desde la API')),
    );
  }
}
