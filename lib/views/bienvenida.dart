import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Fondo gris ultra claro (minimalista)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // Ancho máximo para web/tablet
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icono / Logotipo de bienvenida
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B52A3).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 56,
                          color: Color(0xFF6B52A3),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Título Principal
                      Text(
                        "Bienvenido a\nChatbot Helper",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          letterSpacing: -0.5,
                          color: const Color(0xFF111827), // Texto oscuro profesional
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Párrafo de contexto
                      Text(
                        "Esta aplicación tiene como objetivo informar sobre la Violencia Sexual Basada en Género (VSBG), proporcionar marcos legales, ejemplos y situaciones reales en diferentes contextos.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          height: 1.6,
                          color: const Color(0xFF4B5563), // Texto gris oscuro para lectura
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Párrafo de la herramienta
                      Text(
                        "Podrás dialogar de manera confidencial con un Asistente Especializado para analizar situaciones de riesgo y obtener información sobre centros de ayuda.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          height: 1.6,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Botón de Acción a lo ancho de la tarjeta
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(), // Cambiamos a la nueva pantalla
                                ),
                              );
                            },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6B52A3), // Color primario
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Bordes consistentes con el diseño Enterprise
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Comenzar",
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}