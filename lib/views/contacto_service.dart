import 'package:supabase_flutter/supabase_flutter.dart';
import 'contacto_model.dart';

class ContactoService {
  final _supabase = Supabase.instance.client;

  // Obtener la lista de contactos de la usuaria actual
  Future<List<ContactoEmergencia>> obtenerContactos() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('contactos_emergencia')
          .select()
          .eq('user_id', userId);

      return (response as List).map((json) => ContactoEmergencia.fromMap(json)).toList();
    } catch (e) {
      print("Error al obtener contactos: $e");
      return [];
    }
  }

  // Agregar un nuevo contacto (Validando un límite máximo, por ejemplo, 3)
  Future<bool> agregarContacto(String nombre, String telefono, String? relacion) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verificar límite actual antes de insertar
      final actuales = await obtenerContactos();
      if (actuales.length >= 3) return false; 

      final nuevoContacto = ContactoEmergencia(
        userId: userId,
        nombre: nombre,
        telefono: telefono,
        relacion: relacion,
      );

      await _supabase.from('contactos_emergencia').insert(nuevoContacto.toMap());
      return true;
    } catch (e) {
      print("Error al agregar contacto: $e");
      return false;
    }
  }
}