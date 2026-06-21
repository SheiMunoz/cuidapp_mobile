import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cuidapp_mobile/services/api_service.dart';

class _TipoDocumento {
  final String valor;
  final String label;
  final IconData icono;
  final Color color;

  const _TipoDocumento(this.valor, this.label, this.icono, this.color);
}

const List<_TipoDocumento> _tipos = [
  _TipoDocumento(
    'medicion',
    'Foto de Medición',
    Icons.monitor_heart,
    Color(0xFF1E88E5),
  ),
  _TipoDocumento(
    'receta',
    'Receta Médica',
    Icons.description,
    Color(0xFF43A047),
  ),
  _TipoDocumento(
    'indicacion',
    'Indicación Médica',
    Icons.assignment,
    Color(0xFFFFB300),
  ),
  _TipoDocumento('otro', 'Otro Documento', Icons.folder, Color(0xFF546E7A)),
];

class AbueloSubirDocumento extends StatefulWidget {
  const AbueloSubirDocumento({super.key});

  @override
  State<AbueloSubirDocumento> createState() => _AbueloSubirDocumentoState();
}

class _AbueloSubirDocumentoState extends State<AbueloSubirDocumento> {
  bool _subiendo = false;

  Future<void> _elegirTipoYSubir(_TipoDocumento tipo) async {
    final origen = await _elegirOrigen();
    if (origen == null) return;

    final picker = ImagePicker();
    final XFile? archivo = await picker.pickImage(
      source: origen,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (archivo == null) return;

    setState(() => _subiendo = true);

    final resultado = await ApiService.subirFoto(
      imagen: File(archivo.path),
      tipo: tipo.valor,
    );

    if (!mounted) return;
    setState(() => _subiendo = false);

    if (resultado['ok'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tipo.label} subida correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Error al subir el documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ImageSource?> _elegirOrigen() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Sacar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      appBar: AppBar(
        title: const Text(
          'Subir documento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 140, 236),
        foregroundColor: Colors.white,
      ),
      body: _subiendo
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¿Qué querés subir?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: _tipos
                          .map((tipo) => _buildTipoButton(tipo))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTipoButton(_TipoDocumento tipo) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: tipo.color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      onPressed: () => _elegirTipoYSubir(tipo),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tipo.icono, size: 48),
          const SizedBox(height: 10),
          Text(
            tipo.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
