import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/bot_api.dart';

class ChatMessage {
  final String mensaje;
  final bool esUsuario;

  ChatMessage({
    required this.mensaje,
    required this.esUsuario,
  });
}

class ChatBotView extends StatefulWidget {
  final bool isWeb;

  const ChatBotView({
    super.key,
    required this.isWeb,
  });

  @override
  State<ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<ChatMessage> _mensajes = [];

  List<dynamic> _botones = [];

  bool _bloquearEntrada = false;

  bool _escribiendo = false;

  @override
  void initState() {
    super.initState();

    _mensajes.add(
      ChatMessage(
        mensaje:
            "Hola. Este es un entorno completamente seguro, confidencial y anónimo. ¿En qué puedo orientarte hoy?",
        esUsuario: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollAbajo() {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }
  Future<void> _enviarMensaje() async {
    final mensaje = _controller.text.trim();

    if (mensaje.isEmpty || _bloquearEntrada) return;

    setState(() {
      _mensajes.add(
        ChatMessage(
          mensaje: mensaje,
          esUsuario: true,
        ),
      );

      _controller.clear();

      _escribiendo = true;
    });

    _scrollAbajo();

    try {
      final respuesta =
          await AuroraApi.enviarMensaje(mensaje);

      setState(() {
        _mensajes.add(
          ChatMessage(
            mensaje: respuesta["respuesta_bot"] ??
                "No se recibió respuesta.",
            esUsuario: false,
          ),
        );

        _botones =
            respuesta["botones_activos"] ?? [];

        _bloquearEntrada =
            respuesta["bloquear_entrada_texto"] ??
                false;

        _escribiendo = false;
      });

      _scrollAbajo();
    } catch (e) {
      setState(() {
        _mensajes.add(
          ChatMessage(
            mensaje:
                "No fue posible conectar con Aurora.\n\n$e",
            esUsuario: false,
          ),
        );

        _escribiendo = false;
      });

      _scrollAbajo();
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6F3CC3),
        title: Text(
          "Aurora",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {

                  final mensaje = _mensajes[index];

                  return _buildChatBubble(
                    mensaje: mensaje,
                  );
                },
              ),
            ),

            if (_escribiendo)
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Aurora está escribiendo...",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            if (_botones.isNotEmpty)
              _buildBotones(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              color: Colors.white,
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_bloquearEntrada,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensaje(),
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        const Color(0xFF6F3CC3),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildChatBubble({
    required ChatMessage mensaje,
  }) {
    final bool esUsuario = mensaje.esUsuario;

    return Align(
      alignment:
          esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esUsuario
              ? const Color(0xFF6F3CC3)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(esUsuario ? 18 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          mensaje.mensaje,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: esUsuario ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
Widget _buildBotones() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _botones.map<Widget>((boton) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F3CC3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () async {
              final accion = boton["accion"] ?? "";

              if (accion == "cerrar_app") {
                Navigator.pop(context);
                return;
              }

              if (accion.startsWith("enviar_mensaje:")) {
                final mensaje = accion.replaceFirst(
                  "enviar_mensaje:",
                  "",
                ).trim();

                _controller.text = mensaje;
                await _enviarMensaje();
              }
            },
            child: Text(
              boton["label"] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}