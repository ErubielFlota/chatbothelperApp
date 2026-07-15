import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapaInstitucionesView extends StatefulWidget {
  final bool isWeb;
  
  const MapaInstitucionesView({super.key, required this.isWeb});

  @override
  State<MapaInstitucionesView> createState() => _MapaInstitucionesViewState();
}

class _MapaInstitucionesViewState extends State<MapaInstitucionesView> {
  // Coordenadas centrales (Entre Bello y Medellín)
  final LatLng _centroMapa = const LatLng(6.2900, -75.5600);
  
  List<Marker> _marcadores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarInstituciones();
  }

  Future<void> _cargarInstituciones() async {
    try {
      // Hacemos el SELECT a la tabla que acabas de crear
      final response = await Supabase.instance.client
          .from('instituciones_apoyo')
          .select();

      final List<Marker> marcadoresTemp = [];

      for (var institucion in response) {
        final double lat = institucion['latitud'] is int 
            ? (institucion['latitud'] as int).toDouble() 
            : institucion['latitud'];
        final double lng = institucion['longitud'] is int 
            ? (institucion['longitud'] as int).toDouble() 
            : institucion['longitud'];

        marcadoresTemp.add(
          Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _mostrarInfoInstitucion(
                institucion['nombre'] ?? 'Sin nombre',
                institucion['direccion'] ?? 'Sin dirección',
                institucion['telefono'] ?? 'Sin teléfono',
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFD32F2F), // Rojo para destacar
                size: 40,
              ),
            ),
          ),
        );
      }

      setState(() {
        _marcadores = marcadoresTemp;
        _cargando = false;
      });
    } catch (e) {
      debugPrint("Error al cargar marcadores: $e");
      setState(() {
        _cargando = false;
      });
    }
  }

  // Cuadro de diálogo que sale al tocar un pin
  void _mostrarInfoInstitucion(String nombre, String direccion, String telefono) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_city_rounded, color: Color(0xFF6B52A3)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      direccion,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF49454F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF6B52A3)),
                  const SizedBox(width: 8),
                  Text(
                    telefono,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF49454F)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6B52A3),
                  ),
                  child: const Text("Cerrar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Puntos de Apoyo",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B20),
        elevation: 0,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B52A3)))
          : FlutterMap(
              options: MapOptions(
                initialCenter: _centroMapa,
                initialZoom: 12.5, // Zoom perfecto para ver el área metropolitana
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Desactiva rotación para no marear al usuario
                ),
              ),
              children: [
                TileLayer(
                  // Usamos OpenStreetMap gratuito
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tu_usuario.vozsegura', // Cambia esto si tienes un package name definido
                ),
                MarkerLayer(
                  markers: _marcadores,
                ),
              ],
            ),
    );
  }
}