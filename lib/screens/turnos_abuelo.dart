import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cuidapp_mobile/services/api_service.dart';

class TurnosAbueloScreen extends StatefulWidget {
  const TurnosAbueloScreen({super.key});

  @override
  State<TurnosAbueloScreen> createState() => _TurnosAbueloScreenState();
}

class _TurnosAbueloScreenState extends State<TurnosAbueloScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _cargando = true;
  bool _localeListo = false;
  String? _error;

  // Eventos agrupados por día (clave normalizada a medianoche)
  Map<DateTime, List<Map<String, dynamic>>> _eventosPorDia = {};
  Map<String, dynamic>? _proximoEvento;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _inicializar();
  }

  Future<void> _inicializar() async {
    await initializeDateFormatting('es_ES', null);
    if (mounted) {
      setState(() {
        _localeListo = true;
      });
    }
    await _cargarEventos();
  }

  DateTime _normalizar(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _cargarEventos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final eventos = await ApiService.getEventos();
      final Map<DateTime, List<Map<String, dynamic>>> agrupados = {};

      for (final ev in eventos) {
        final evento = Map<String, dynamic>.from(ev as Map);
        final fechaHoraRaw = evento['fecha_hora'];
        if (fechaHoraRaw == null) continue;

        final fechaHora = DateTime.parse(fechaHoraRaw.toString()).toLocal();
        final dia = _normalizar(fechaHora);
        agrupados.putIfAbsent(dia, () => []);
        agrupados[dia]!.add(evento);
      }

      // Ordenamos cada día por hora
      for (final lista in agrupados.values) {
        lista.sort(
          (a, b) => DateTime.parse(
            a['fecha_hora'].toString(),
          ).compareTo(DateTime.parse(b['fecha_hora'].toString())),
        );
      }

      // Buscamos el próximo evento (el más cercano que todavía no pasó)
      final ahora = DateTime.now();
      final todos = agrupados.values.expand((lista) => lista).toList()
        ..sort(
          (a, b) => DateTime.parse(
            a['fecha_hora'].toString(),
          ).compareTo(DateTime.parse(b['fecha_hora'].toString())),
        );
      final proximo = todos.firstWhere(
        (ev) => DateTime.parse(
          ev['fecha_hora'].toString(),
        ).toLocal().isAfter(ahora),
        orElse: () => <String, dynamic>{},
      );

      if (mounted) {
        setState(() {
          _eventosPorDia = agrupados;
          _proximoEvento = proximo.isNotEmpty ? proximo : null;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar los turnos. Probá de nuevo.';
          _cargando = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _eventosDelDia(DateTime day) {
    return _eventosPorDia[_normalizar(day)] ?? [];
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'medico':
        return const Color(0xFF1E88E5);
      case 'social':
        return const Color(0xFF43A047);
      case 'actividad':
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'medico':
        return Icons.local_hospital;
      case 'social':
        return Icons.people;
      case 'actividad':
        return Icons.event;
      default:
        return Icons.event_note;
    }
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarDetalle(Map<String, dynamic> evento) {
    final fechaHora = DateTime.parse(evento['fecha_hora'].toString()).toLocal();
    final tipo = (evento['tipo'] ?? '').toString();
    final tipoDisplay = (evento['tipo_display'] ?? tipo).toString();
    final lugar = (evento['lugar'] ?? '').toString();
    final descripcion = (evento['descripcion'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _colorPorTipo(tipo),
                    child: Icon(_iconoPorTipo(tipo), color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      (evento['titulo'] ?? 'Turno').toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _filaDetalle(Icons.category, 'Tipo', tipoDisplay),
              const SizedBox(height: 10),
              _filaDetalle(
                Icons.calendar_today,
                'Fecha',
                '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} - ${_formatearHora(fechaHora)} hs',
              ),
              if (lugar.isNotEmpty) ...[
                const SizedBox(height: 10),
                _filaDetalle(Icons.place, 'Lugar', lugar),
              ],
              if (descripcion.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 17, height: 1.3),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filaDetalle(IconData icon, String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $valor', style: const TextStyle(fontSize: 17)),
        ),
      ],
    );
  }

  Widget _buildProximoEventoCard() {
    final evento = _proximoEvento!;
    final fechaHora = DateTime.parse(evento['fecha_hora'].toString()).toLocal();
    final tipo = (evento['tipo'] ?? '').toString();
    final tipoDisplay = (evento['tipo_display'] ?? tipo).toString();
    final lugar = (evento['lugar'] ?? '').toString();
    final color = _colorPorTipo(tipo);

    final hoy = _normalizar(DateTime.now());
    final diaEvento = _normalizar(fechaHora);
    String cuando;
    if (diaEvento == hoy) {
      cuando = 'Hoy a las ${_formatearHora(fechaHora)} hs';
    } else if (diaEvento == hoy.add(const Duration(days: 1))) {
      cuando = 'Mañana a las ${_formatearHora(fechaHora)} hs';
    } else {
      cuando =
          '${fechaHora.day}/${fechaHora.month} a las ${_formatearHora(fechaHora)} hs';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _mostrarDetalle(evento),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(_iconoPorTipo(tipo), color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximo turno',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (evento['titulo'] ?? 'Turno').toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$cuando'
                      '${lugar.isNotEmpty ? ' • $lugar' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      tipoDisplay,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventosSeleccionados = _selectedDay != null
        ? _eventosDelDia(_selectedDay!)
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Turnos Médicos'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: (_cargando || !_localeListo)
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cargarEventos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TableCalendar<Map<String, dynamic>>(
                      locale: 'es_ES',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: _eventosDelDia,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mes',
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
                        weekendStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      calendarStyle: const CalendarStyle(
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                        ),
                        markerSize: 8,
                        markerMargin: EdgeInsets.only(top: 4),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF009688),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Color(0xFFB2DFDB),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(color: Colors.black87),
                        defaultTextStyle: TextStyle(fontSize: 16),
                        weekendTextStyle: TextStyle(fontSize: 16),
                        selectedTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final tieneEventos = _eventosDelDia(day).isNotEmpty;
                          if (!tieneEventos) return null;
                          return Container(
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5).withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1E88E5),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          );
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                if (_proximoEvento != null) _buildProximoEventoCard(),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDay != null
                          ? 'Turnos del ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                          : 'Turnos',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: eventosSeleccionados.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay turnos para este día',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: eventosSeleccionados.length,
                          itemBuilder: (context, index) {
                            final evento = eventosSeleccionados[index];
                            final fechaHora = DateTime.parse(
                              evento['fecha_hora'].toString(),
                            ).toLocal();
                            final tipo = (evento['tipo'] ?? '').toString();
                            final tipoDisplay = (evento['tipo_display'] ?? tipo)
                                .toString();
                            final lugar = (evento['lugar'] ?? '').toString();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _colorPorTipo(tipo),
                                  child: Icon(
                                    _iconoPorTipo(tipo),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  (evento['titulo'] ?? 'Turno').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  '$tipoDisplay • ${_formatearHora(fechaHora)} hs'
                                  '${lugar.isNotEmpty ? ' • $lugar' : ''}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _mostrarDetalle(evento),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
