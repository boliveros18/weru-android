class NovedadServicio {
  final int? id;
  final int idServicio;
  final int idNovedad;

  NovedadServicio({
    this.id,
    required this.idServicio,
    required this.idNovedad,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idNovedad': idNovedad,
    };
  }

  factory NovedadServicio.fromMap(Map<String, dynamic> map) {
    return NovedadServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      idNovedad: int.tryParse(map['idNovedad']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'NovedadServicio{id: $id, idServicio: $idServicio, idNovedad: $idNovedad}';
  }
}
