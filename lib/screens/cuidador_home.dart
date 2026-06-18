import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cuidador_perfil.dart';

class CuidadorHome extends StatefulWidget {
  const CuidadorHome({super.key});

  @override
  State<CuidadorHome> createState() => _CuidadorHomeState();
}

class _CuidadorHomeState extends State<CuidadorHome> {
  late final Future<List<dynamic>?> _futureAbuelos;

  @override
  void initState() {
    super.initState();
    _futureAbuelos = ApiService.getAbuelosACargo();
  }

  String _nombreDeAbuelo(Map<String, dynamic> abuelo) {
    if (abuelo['nombre'] != null &&
        abuelo['nombre'].toString().trim().isNotEmpty) {
      return abuelo['nombre'].toString();
    }
    if (abuelo['name'] != null && abuelo['name'].toString().trim().isNotEmpty) {
      return abuelo['name'].toString();
    }
    final firstName = abuelo['first_name']?.toString() ?? '';
    final lastName = abuelo['last_name']?.toString() ?? '';
    final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
    return fullName.isNotEmpty ? fullName : 'Abuelo sin nombre';
  }

  String _detalleDeAbuelo(Map<String, dynamic> abuelo) {
    final edad = abuelo['edad'] != null ? 'Edad ${abuelo['edad']}' : '';
    final condicion =
        abuelo['condicion'] ?? abuelo['diagnostico'] ?? abuelo['detalle'] ?? '';
    final parts = [
      edad,
      condicion.toString().trim(),
    ].where((value) => value.isNotEmpty).toList();
    return parts.isEmpty ? 'Detalle no disponible' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 140, 236),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 140,
                      width: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cuida App',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
              const SizedBox(height: 32),
              const Text(
                'Abuelos a cargo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>?>(
                  future: _futureAbuelos,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar los abuelos. Intentá de nuevo.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final abuelos = snapshot.data;
                    if (abuelos == null || abuelos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay abuelos asignados todavía.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: abuelos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final abuelo = Map<String, dynamic>.from(
                          abuelos[index] as Map,
                        );
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            title: Text(
                              _nombreDeAbuelo(abuelo),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _detalleDeAbuelo(abuelo),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.person, size: 28),
                label: const Text(
                  'Ir a mi perfil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuidadorPerfil(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
