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

  Future<void> _marcarComoTomado(int idMedicamento, String nombre) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final resultado = await ApiService.registrarToma(idMedicamento);

    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    if (resultado['ok']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Excelente! Registraste la toma de $nombre.'),
          backgroundColor: Colors.green,
        ),
      );
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
                final puedeTomar = med['puede_tomar_ahora'] == true;
                final proximaToma = med['proxima_toma_texto'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medication,
                              color: Colors.blue,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: puedeTomar
                                    ? Colors.green
                                    : Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: puedeTomar
                                  ? () => _marcarComoTomado(
                                      med['id'],
                                      med['nombre'],
                                    )
                                  : null,
                              child: const Text(
                                'Tomar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!puedeTomar) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.deepOrange,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    proximaToma != null
                                        ? 'Ya la tomaste. Próxima toma: $proximaToma'
                                        : 'Ya la tomaste hoy',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
