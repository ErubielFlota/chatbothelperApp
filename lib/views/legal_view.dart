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
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _buildExpandedLegalCard(
                context: context,
                title: topic['title'] ?? '',
                description: topic['short_description'] ?? '',
                detailedContent: topic['detailed_content'] ?? '',
                icon: _getIconData(topic['icon_identifier']),
              );
            },
          );
        }

        final mainContent = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40.0 : 20.0, 
            vertical: 24.0
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Marco Legal y Derechos",
                style: GoogleFonts.dmSans(
                  fontSize: isWeb ? 32 : 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Información estructurada sobre normativas vigentes, derechos de las víctimas y rutas institucionales de denuncia.",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              
              // Aquí se renderiza la lista dinámica desde Supabase
              dynamicContent,
              
              SizedBox(height: isWeb ? 40 : 100), // Evita colisiones visuales en móvil
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

  // Tarjeta modificada para soportar expansión manteniendo tu diseño original de UI
  Widget _buildExpandedLegalCard({
    required BuildContext context,
    required String title,
    required String description,
    required String detailedContent,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: Theme(
        // Remueve las líneas divisorias y el sombreado por defecto que trae ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(24),
          childrenPadding: const EdgeInsets.only(left: 88, right: 24, bottom: 24),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB8FF).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B52A3)),
          ),
          title: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
          ),
          // Icono de flecha estilizado
          trailing: const Icon(Icons.expand_more_rounded, color: Color(0xFF6B52A3)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                detailedContent,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}