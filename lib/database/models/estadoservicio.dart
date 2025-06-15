class EstadoServicio {
  final int id;
  final String nombre;
  final String descripcion;

  EstadoServicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory EstadoServicio.unknown() {
    return EstadoServicio(
      id: 0,
      nombre: 'Desconocido',
      descripcion: 'Desconocido',
    );
  }

  factory EstadoServicio.fromMap(Map<String, dynamic> map) {
    return EstadoServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'EstadoServicio{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
