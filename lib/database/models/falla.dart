class Falla {
  final int id;
  final String descripcion;
  final int estado;

  Falla({
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

  factory Falla.unknown() {
    return Falla(
      id: 0,
      descripcion: 'Desconocida',
      estado: 0,
    );
  }

  factory Falla.fromMap(Map<String, dynamic> map) {
    return Falla(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
      estado: int.tryParse(map['estado']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Falla{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
