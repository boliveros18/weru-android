class Modelo {
  final int id;
  final String descripcion;

  Modelo({
    required this.id,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

  factory Modelo.unknown() {
    return Modelo(
      id: 0,
      descripcion: 'Desconocido',
    );
  }

  factory Modelo.fromMap(Map<String, dynamic> map) {
    return Modelo(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Modelo{id: $id, descripcion: $descripcion}';
  }
}
