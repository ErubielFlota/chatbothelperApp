class ContactoEmergencia {
  final String? id;
  final String userId;
  final String nombre;
  final String telefono;
  final String? relacion;

  ContactoEmergencia({
    this.id,
    required this.userId,
    required this.nombre,
    required this.telefono,
    this.relacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nombre': nombre,
      'telefono': telefono,
      'relacion': relacion,
    };
  }

  factory ContactoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      id: map['id'],
      userId: map['user_id'],
      nombre: map['nombre'],
      telefono: map['telefono'],
      relacion: map['relacion'],
    );
  }
}