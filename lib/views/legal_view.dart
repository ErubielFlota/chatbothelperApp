import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LegalView extends StatelessWidget {
  final bool isWeb;

  const LegalView({super.key, required this.isWeb});

  // Función para consultar Supabase respetando el orden establecido
  Future<List<Map<String, dynamic>>> _fetchLegalTopics() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('legal_frameworks')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);
    return response;
  }

  // Mapeador de strings de la BD a iconos nativos de Flutter
  IconData _getIconData(String? iconIdentifier) {
    switch (iconIdentifier) {
      case 'shield':
        return Icons.shield_rounded;
      case 'gavel':
      default:
        return Icons.gavel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLegalTopics(),
      builder: (context, snapshot) {
        Widget dynamicContent;

        if (snapshot.connectionState == ConnectionState.waiting) {
          dynamicContent = const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF6B52A3))),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          dynamicContent = const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                "No se pudo cargar la información legal o no hay registros.",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        } else {
          final topics = snapshot.data!;
          
          dynamicContent = ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12), // Reducido de 16 a 12
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _buildExpandedLegalCard(
                context: context,
                title: topic['title'] ?? '',
                description: topic['short_description'] ?? '',
                detailedContent: topic['detailed_content'] ?? '',
                icon: _getIconData(topic['icon_identifier']),
                isWeb: isWeb, // Pasamos el parámetro para adaptar la tarjeta
              );
            },
          );
        }

        final mainContent = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40.0 : 20.0, 
            vertical: isWeb ? 24.0 : 16.0 // Menos padding superior en móvil
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Marco Legal y Derechos",
                style: GoogleFonts.dmSans(
                  fontSize: isWeb ? 32 : 24, // Escala adaptada
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
              ),
              SizedBox(height: isWeb ? 8 : 4),
              Text(
                "Información estructurada sobre normativas vigentes, derechos de las víctimas y rutas institucionales de denuncia.",
                style: TextStyle(fontSize: isWeb ? 15 : 14, color: Colors.black54), // Texto más ligero
              ),
              const SizedBox(height: 24), // Reducido de 32 a 24
              
              // Aquí se renderiza la lista dinámica desde Supabase
              dynamicContent,
              
              SizedBox(height: isWeb ? 40 : 100), 
            ],
          ),
        );

        if (isWeb) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: mainContent,
              ),
            ),
          );
        }

        return SingleChildScrollView(child: mainContent);
      },
    );
  }

  Widget _buildExpandedLegalCard({
    required BuildContext context,
    required String title,
    required String description,
    required String detailedContent,
    required IconData icon,
    required bool isWeb,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWeb ? 20 : 16), // Bordes más suaves en móvil
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Paddings reducidos dinámicamente para versión móvil
          tilePadding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: isWeb ? 8 : 4),
          childrenPadding: EdgeInsets.only(
            left: isWeb ? 88 : 64, // El texto se alinea un poco más a la izquierda en móvil
            right: isWeb ? 24 : 16, 
            bottom: isWeb ? 24 : 16
          ),
          leading: Container(
            padding: EdgeInsets.all(isWeb ? 12 : 10), // Círculo de ícono más pequeño
            decoration: BoxDecoration(
              color: const Color(0xFFEAB8FF).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B52A3), size: isWeb ? 24 : 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: isWeb ? 18 : 16, // Tamaño de fuente optimizado
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0), // Menos espacio entre título y subtítulo
            child: Text(
              description,
              style: TextStyle(fontSize: isWeb ? 14 : 13, color: Colors.black54, height: 1.4),
            ),
          ),
          trailing: const Icon(Icons.expand_more_rounded, color: Color(0xFF6B52A3)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                detailedContent,
                style: GoogleFonts.dmSans(
                  fontSize: isWeb ? 14 : 13, // Texto detallado ligeramente menor
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}