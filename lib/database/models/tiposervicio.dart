class TipoServicio {
  final int id;
  final String descripcion;

  TipoServicio({
    required this.id,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

  factory TipoServicio.unknown() {
    return TipoServicio(
      id: 0,
      descripcion: 'Desconocido',
    );
  }

  factory TipoServicio.fromMap(Map<String, dynamic> map) {
    return TipoServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'TipoServicio{id: $id, descripcion: $descripcion}';
  }
}
