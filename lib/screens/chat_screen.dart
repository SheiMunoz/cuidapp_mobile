import 'package:flutter/material.dart';
import 'package:cuidapp_mobile/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int otroId;
  final String nombreOtro;

  const ChatScreen({super.key, required this.otroId, required this.nombreOtro});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _mensajes = [];
  bool _cargando = true;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarMensajes({bool mostrarLoader = true}) async {
    if (mostrarLoader) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final data = await ApiService.getMensajes(widget.otroId);
      if (!mounted) return;
      setState(() {
        _mensajes = data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _cargando = false;
      });
      _irAlFinal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los mensajes.';
        _cargando = false;
      });
    }
  }

  void _irAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    final resultado = await ApiService.enviarMensaje(widget.otroId, texto);
    if (!mounted) return;

    if (resultado['ok'] == true) {
      _controller.clear();
      final nuevo = Map<String, dynamic>.from(resultado['data'] as Map);
      setState(() {
        _mensajes.add(nuevo);
        _enviando = false;
      });
      _irAlFinal();
    } else {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['error'] ?? 'No se pudo enviar')),
      );
    }
  }

  String _formatearHora(String fechaIso) {
    final fecha = DateTime.parse(fechaIso).toLocal();
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(widget.nombreOtro),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _cargarMensajes(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _mensajes.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no hay mensajes.\n¡Escribí el primero!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _cargarMensajes(mostrarLoader: false),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _mensajes.length,
                      itemBuilder: (context, index) {
                        final m = _mensajes[index];
                        final esMio = m['es_mio'] == true;
                        return Align(
                          alignment: esMio
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: esMio
                                  ? const Color(0xFF1E88E5)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(esMio ? 14 : 2),
                                bottomRight: Radius.circular(esMio ? 2 : 14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (m['texto'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: esMio
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatearHora(m['fecha_envio'].toString()),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: esMio
                                        ? Colors.white70
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribí un mensaje...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _enviar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1E88E5),
                    child: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _enviar,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
