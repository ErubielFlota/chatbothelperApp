import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _mensajes = [];
  List<dynamic> _botones = [];
  bool _bloquearEntrada = false;
  bool _escribiendo = false;
  bool _sesionFinalizada = false;

  // Cliente de Supabase y variable para rastrear la sesión de chat
  final _supabase = Supabase.instance.client;
  String? _conversacionId;
  bool _esInvitado = false;
  

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

    _inicializarConversacion();
  }

  void _confirmarLimpieza() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "¿Limpiar historial?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6F3CC3),
            ),
          ),
          content: Text(
            "Se eliminarán todos los mensajes de esta conversación. Esta acción no se puede deshacer.",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
              child: Text(
                "Cancelar",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _limpiarConversacion();      // Ejecuta el borrado
              },
              child: Text(
                "Eliminar",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD32F2F), // Rojo para indicar acción destructiva
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _limpiarConversacion() async {
    // 1. Borrar en Supabase solo si el usuario inició sesión
    if (!_esInvitado && _conversacionId != null) {
      try {
        await _supabase
            .from('mensajes')
            .delete()
            .eq('conversacion_id', _conversacionId!);
      } catch (e) {
        debugPrint("Error eliminando historial en BD: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hubo un error al intentar borrar el historial en la nube.")),
        );
        return; // Salimos si falla la base de datos para no desincronizar la vista
      }
    }

    // 2. Limpiar la interfaz (Vista)
    setState(() {
      _mensajes.clear();
      
      // Volvemos a colocar el mensaje inicial del bot
      _mensajes.add(
        ChatMessage(
          mensaje: "Hola. Este es un entorno completamente seguro, confidencial y anónimo. ¿En qué puedo orientarte hoy?",
          esUsuario: false,
        ),
      );

      // Reiniciamos los estados por si estaba en modo emergencia o con botones
      _botones = [];
      _bloquearEntrada = false;
      _escribiendo = false;
    });

    // Pequeño aviso visual de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Historial eliminado correctamente",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: const Color(0xFF6F3CC3),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _inicializarConversacion() async {
    final userId = _supabase.auth.currentUser?.id;
    
    // Verificación de usuario no logueado
    if (userId == null) {
      setState(() {
        _esInvitado = true;
      });
      
      // Usamos addPostFrameCallback para asegurar que el widget ya se construyó
      // antes de intentar mostrar el cuadro de diálogo emergente.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarAlertaInvitado();
      });
      return; // Salimos del método para no intentar consultar la base de datos
    } 

    // Si el usuario SÍ está logueado, procedemos con Supabase
    setState(() {
      _esInvitado = false;
    });

    try {
      final response = await _supabase
          .from('conversaciones')
          .select()
          .eq('perfil_id', userId)
          .eq('estado', 'activa')
          .maybeSingle();

      if (response != null) {
        _conversacionId = response['id'];
        await _cargarHistorial();
      } else {
        final nuevaConv = await _supabase
            .from('conversaciones')
            .insert({
              'perfil_id': userId,
              'estado': 'activa',
            })
            .select()
            .single();

        _conversacionId = nuevaConv['id'];
      }
    } catch (e) {
      debugPrint('Error al inicializar conversación: $e');
    }
  }

  // Función sencilla para simular la llamada y no repetir código
  void _simularLlamadaEmergencia() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Llamando a emergencias...",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFB71C1C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }



  void _mostrarAlertaInvitado() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a tocar un botón
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF6F3CC3)),
              const SizedBox(width: 10),
              Text(
                "Modo Invitado",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6F3CC3),
                ),
              ),
            ],
          ),
          content: Text(
            "Actualmente estás usando Aurora sin iniciar sesión. Puedes chatear libremente, pero ten en cuenta que para guardar un historial de tus conversaciones y acceder a todas las funciones, deberás registrarte e iniciar sesión.",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text(
                "Entendido",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6F3CC3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> _cargarHistorial() async {
    if (_conversacionId == null) return;

    try {
      final response = await _supabase
          .from('mensajes')
          .select()
          .eq('conversacion_id', _conversacionId!)
          .order('enviado_en', ascending: true); 

      if (response.isNotEmpty) {
        setState(() {
          for (var row in response) {
            _mensajes.add(ChatMessage(
              mensaje: row['contenido'],
              esUsuario: row['remitente'] == 'usuario',
            ));
          }
        });
        _scrollAbajo();
      }
    } catch (e) {
      debugPrint('Error al cargar historial: $e');
    }
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

    // 1. Guardar el mensaje del usuario SOLO si NO es invitado
    if (!_esInvitado && _conversacionId != null) {
      try {
        await _supabase.from('mensajes').insert({
          'conversacion_id': _conversacionId,
          'remitente': 'usuario',
          'contenido': mensaje,
        });
      } catch (e) {
        debugPrint("Error guardando mensaje usuario: $e");
      }
    }

    try {
      final respuesta = await AuroraApi.enviarMensaje(mensaje);
      final textoRespuestaBot = respuesta["respuesta_bot"] ?? "No se recibió respuesta.";

      setState(() {
        _mensajes.add(
          ChatMessage(
            mensaje: textoRespuestaBot,
            esUsuario: false,
          ),
        );

        _botones = respuesta["botones_activos"] ?? [];
        _bloquearEntrada = respuesta["bloquear_entrada_texto"] ?? false;
        _escribiendo = false;
      });

      _scrollAbajo();

      // 2. Guardar la respuesta del bot SOLO si NO es invitado
      if (!_esInvitado && _conversacionId != null) {
        try {
          await _supabase.from('mensajes').insert({
            'conversacion_id': _conversacionId,
            'remitente': 'bot',
            'contenido': textoRespuestaBot,
          });
        } catch (e) {
          debugPrint("Error guardando mensaje bot: $e");
        }
      }
    } catch (e) {
      setState(() {
        _mensajes.add(
          ChatMessage(
            mensaje: "No fue posible conectar con Aurora.\n\n$e",
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
        actions: [
          
          IconButton(
            icon: const Icon(Icons.emergency, color: Color(0xFFFF5252)), // Color rojo claro para que resalte en el fondo morado
            tooltip: 'Llamar a emergencias',
            onPressed: _simularLlamadaEmergencia, // Llama a la función que creamos
          ),



          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Limpiar conversación',
            onPressed: _confirmarLimpieza,
          ),
        ],
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

            if (_botones.isNotEmpty || _bloquearEntrada) 
              _buildBotones(),

            // Se oculta la barra de texto por completo si estamos en modo emergencia
            if (!_bloquearEntrada)
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
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviarMensaje(),
                        decoration: InputDecoration(
                          hintText: "Escribe un mensaje...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF6F3CC3),
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
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
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
          color: esUsuario ? const Color(0xFF6F3CC3) : Colors.white,
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
    // Si la entrada está bloqueada, mostramos las opciones de emergencia
    if (_bloquearEntrada) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // --- BOTÓN 1: LLAMAR A EMERGENCIAS ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), // Rojo alerta
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 80), 
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.emergency, 
                size: 35,
              ),
              label: Text(
                "LLAMAR A\nEMERGENCIAS", 
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
              onPressed: () {
                // Acción simulada de llamada
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.phone_in_talk, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Llamando a emergencias...",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFB71C1C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),

            const SizedBox(height: 16), // Espacio de separación entre los botones

            // --- BOTÓN 2: AVISAR A CONTACTOS ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100), // Naranja oscuro para diferenciarlo
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 80),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.message_rounded, 
                size: 35,
              ),
              label: Text(
                "AVISAR A\nCONTACTOS", 
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
              onPressed: () {
                // Acción simulada de envío de mensajes
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.send_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Enviando alerta a tus contactos...",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFE65100),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // Si NO hay código rojo, dibujamos los botones regulares que manda la API
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
                setState(() {
                  _botones = []; 
                  _bloquearEntrada = false;
                  _sesionFinalizada= true;
                  _mensajes.add(
                    ChatMessage(
                      mensaje: "Sesión finalizada. Recuerda que siempre estaré aquí si necesitas hablar. ¡Cuídate mucho!",
                      esUsuario: false,
                    ),
                  );
                });
                
                // Bajamos el scroll para que se vea el mensaje
                _scrollAbajo(); 
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