class Ciudad {
  final int id;
  final String nombre;
  final int estado;

  Ciudad({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
    };
  }

  factory Ciudad.unknown() {
    return Ciudad(
      id: 0,
      nombre: 'Desconocido',
      estado: 0,
    );
  }

  factory Ciudad.fromMap(Map<String, dynamic> map) {
    return Ciudad(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      estado: int.tryParse(map['estado']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Ciudad{id: $id, nombre: $nombre, estado: $estado}';
  }
}
