import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBotView extends StatelessWidget {
  final bool isWeb;

  const ChatBotView({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final chatInterface = Column(
      children: [
        // Área de Mensajes de la Conversación
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildChatBubble(
                message: "Hola. Este es un entorno completamente seguro, confidencial y anónimo. ¿En qué puedo orientarte hoy?",
                isMe: false,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
        // Barra Inferior de Entrada de Texto
        Container(
          margin: EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 10, 
            bottom: isWeb ? 24 : 115, // Ajuste para no chocar con la barra móvil
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Escribe tu mensaje de forma anónima...",
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.dmSans(color: Colors.black38, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {}, 
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF6B52A3),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isWeb) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEBE8F0), width: 1),
            ),
            child: chatInterface,
          ),
        ),
      );
    }

    return chatInterface;
  }

  Widget _buildChatBubble({required String message, required bool isMe, required ColorScheme colorScheme}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF6B52A3) : const Color(0xFFEAB8FF).withAlpha(50),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.dmSans(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}