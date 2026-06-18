import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/services/api_service.dart';

class AbueloMedicamentos extends StatefulWidget {
  const AbueloMedicamentos({super.key});

  @override
  State<AbueloMedicamentos> createState() => _AbueloMedicamentosState();
}

class _AbueloMedicamentosState extends State<AbueloMedicamentos> {
  bool _cargando = true;
  List<dynamic> _medicamentos = [];

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    setState(() => _cargando = true);
    final meds = await ApiService.getMedicamentos();
    if (mounted) {
      setState(() {
        _medicamentos = meds ?? [];
        _cargando = false;
      });
    }
  }

  // Lógica para registrar la toma
  Future<void> _marcarComoTomado(int idMedicamento, String nombre) async {
    // Mostramos un indicador de carga mientras avisa a Django
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final resultado = await ApiService.registrarToma(idMedicamento);

    // Cerramos el indicador de carga
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (resultado['ok']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Excelente! Registraste la toma de $nombre.'),
          backgroundColor: Colors.green,
        ),
      );
      // Volvemos a pedir la lista para que se actualice el stock visualmente
      _cargarMedicamentos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      appBar: AppBar(
        title: const Text(
          'Mis medicamentos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 140, 236),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _medicamentos.isEmpty
          ? const Center(
              child: Text(
                'No tenés medicamentos registrados.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicamentos.length,
              itemBuilder: (context, index) {
                final med = _medicamentos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.medication,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: Text(
                      med['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${med['dosis_por_toma']} ${med['unidad_medida']}',
                        ),
                        Text(
                          'Stock actual: ${med['stock_actual']}',
                          style: TextStyle(
                            color:
                                med['stock_actual'] <=
                                    med['umbral_stock_minimo']
                                ? Colors.red
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // El botón de acción a la derecha
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          _marcarComoTomado(med['id'], med['nombre']),
                      child: const Text(
                        'Tomar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
