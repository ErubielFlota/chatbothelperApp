import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RedApoyoView extends StatefulWidget {
  const RedApoyoView({super.key});

  @override
  State<RedApoyoView> createState() => _RedApoyoViewState();
}

class _RedApoyoViewState extends State<RedApoyoView> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _contactos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarContactos();
  }

  Future<void> _cargarContactos() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('contactos_emergencia')
          .select()
          .eq('user_id', userId)
          .order('orden', ascending: true) // Ahora ordenamos por prioridad
          .order('created_at', ascending: true);

      setState(() {
        _contactos = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      _showMessage("Error al cargar los contactos.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarContacto(String id) async {
    try {
      await _supabase.from('contactos_emergencia').delete().eq('id', id);
      _cargarContactos();
      _showMessage("Contacto eliminado.");
    } catch (e) {
      _showMessage("Error al eliminar el contacto.", isError: true);
    }
  }

  // --- NUEVA LÓGICA DE ORDENAMIENTO ---
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _contactos.removeAt(oldIndex);
      _contactos.insert(newIndex, item);
    });
    _guardarNuevoOrden();
  }

  Future<void> _guardarNuevoOrden() async {
    try {
      // Actualizamos el orden en Supabase para cada contacto
      for (int i = 0; i < _contactos.length; i++) {
        await _supabase
            .from('contactos_emergencia')
            .update({'orden': i})
            .eq('id', _contactos[i]['id']);
      }
    } catch (e) {
      // Fallo silencioso, el usuario ya ve la lista ordenada localmente
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF6B52A3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF221144)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Red de Apoyo",
          style: GoogleFonts.dmSans(
            color: const Color(0xFF221144),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B52A3)))
          : _buildBody(),
      floatingActionButton: _contactos.length < 3
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormularioContacto,
              backgroundColor: const Color(0xFF6B52A3),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("Agregar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_contactos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "Aún no tienes contactos",
                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Agrega hasta 3 personas. Mantén presionado un contacto para cambiar su prioridad.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _contactos.length,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 6,
          color: Colors.transparent,
          shadowColor: Colors.black26,
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final contacto = _contactos[index];
        // Es obligatorio pasar un Key único a cada elemento en ReorderableListView
        return _buildContactoCard(contacto, index, key: ValueKey(contacto['id']));
      },
    );
  }

  Widget _buildContactoCard(Map<String, dynamic> contacto, int index, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6B52A3).withOpacity(0.1),
          child: Text("${index + 1}", style: const TextStyle(color: Color(0xFF6B52A3), fontWeight: FontWeight.bold)),
        ),
        title: Text(
          contacto['nombre'] ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(contacto['telefono'] ?? '', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAB8FF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                contacto['relacion'] ?? 'Familiar',
                style: const TextStyle(color: Color(0xFF6B52A3), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () {
                // Aquí llamamos al nuevo diálogo en lugar de borrar directamente
                _mostrarConfirmacionEliminar(
                  contacto['id'], 
                  contacto['nombre'] ?? 'este contacto'
                );
              },
            ),
            const Icon(Icons.drag_handle_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioContacto() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    String relacionSeleccionada = 'Familiar';
    String ladaSeleccionada = '+52'; // Default a México

    final relaciones = ['Familiar', 'Amistad', 'Pareja (Segura)', 'Vecino/a', 'Institución'];
    final ladas = ['+52', '+57', '+1', '+34', '+54', '+56']; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Nuevo Contacto", style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: "Nombre o Alias",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: ladaSeleccionada,
                            decoration: InputDecoration(
                              labelText: "Lada",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: ladas.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (v) => setModalState(() => ladaSeleccionada = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Teléfono",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) => v!.length < 10 ? "Teléfono inválido" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: relacionSeleccionada,
                      decoration: InputDecoration(
                        labelText: "Parentesco / Relación",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: relaciones.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setModalState(() => relacionSeleccionada = v!),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6B52A3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx);
                            final numeroCompleto = "$ladaSeleccionada ${telefonoController.text.trim()}";
                            await _guardarNuevoContacto(nombreController.text, numeroCompleto, relacionSeleccionada);
                          }
                        },
                        child: const Text("Guardar", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _guardarNuevoContacto(String nombre, String telefonoCompleto, String relacion) async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final ordenActual = _contactos.length; 

      await _supabase.from('contactos_emergencia').insert({
        'user_id': userId,
        'nombre': nombre.trim(),
        'telefono': telefonoCompleto,
        'relacion': relacion,
        'orden': ordenActual,
      });

      _showMessage("Guardado exitosamente.");
      _cargarContactos(); 
    } catch (e) {
      _showMessage("Error al guardar.", isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _mostrarConfirmacionEliminar(String id, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          // Ícono superior característico de Material 3
          icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Bordes más suaves
          backgroundColor: Colors.white,
          title: Text(
            "¿Eliminar a $nombre?",
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF221144)),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Esta persona será removida de tu red de apoyo y no recibirá alertas en caso de emergencia.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          // Alineamos los botones al centro o extendidos para mejor estética
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Cancelar", 
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx); // Cierra el diálogo
                _eliminarContacto(id); // Ejecuta la eliminación
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "Eliminar", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
              ),
            ),
          ],
        );
      },
    );
  }
}