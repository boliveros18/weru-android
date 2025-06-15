class Novedad {
  final int id;
  final String descripcion;
  final int estado;

  Novedad({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  factory Novedad.unknown() {
    return Novedad(id: 0, descripcion: "Desconocido", estado: 0);
  }

  factory Novedad.fromMap(Map<String, dynamic> map) {
    return Novedad(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
      estado: int.tryParse(map['estado']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Novedad{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
