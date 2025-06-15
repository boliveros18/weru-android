class FotoServicio {
  final int? id;
  final int idServicio;
  final String archivo;
  final String comentario;

  FotoServicio({
    this.id,
    required this.idServicio,
    required this.archivo,
    required this.comentario,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'archivo': archivo,
      'comentario': comentario,
    };
  }

  factory FotoServicio.fromMap(Map<String, dynamic> map) {
    return FotoServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      archivo: map['archivo']?.toString() ?? '',
      comentario: map['comentario']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'FotoServicio{id: $id, idServicio: $idServicio, archivo: $archivo, comentario: $comentario}';
  }
}
