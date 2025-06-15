class AdjuntoServicio {
  final int id;
  final int idServicio;
  final int idTecnico;
  final String titulo;
  final String descripcion;
  final String tipo;

  AdjuntoServicio({
    required this.id,
    required this.idServicio,
    required this.idTecnico,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idTecnico': idTecnico,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
    };
  }

   factory   AdjuntoServicio.fromMap(Map<String, dynamic> map) {
    return   AdjuntoServicio(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      idTecnico: int.tryParse(map['idTecnico']?.toString() ?? '') ?? 0,
      titulo: map['titulo']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'AdjuntoServicio{id: $id, idServicio: $idServicio, idTecnico: $idTecnico, titulo: $titulo, descripcion: $descripcion, tipo: $tipo}';
  }
}
