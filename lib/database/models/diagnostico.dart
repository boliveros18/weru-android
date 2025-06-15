class Diagnostico {
  final int id;
  final String descripcion;
  final int estado;

  Diagnostico({
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

  factory Diagnostico.unknown() {
    return Diagnostico(id: 0, descripcion: "Desconocida", estado: 0);
  }

  factory Diagnostico.fromMap(Map<String, dynamic> map) {
    return Diagnostico(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
      estado: int.tryParse(map['estado']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Diagnostico{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
