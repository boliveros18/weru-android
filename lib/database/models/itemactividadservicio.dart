class ItemActividadServicio {
  final int id;
  final int idItem;
  final int? idTipo;
  final int idActividadServicio;
  final double cantidadReq;

  ItemActividadServicio({
    required this.id,
    required this.idItem,
    this.idTipo,
    required this.idActividadServicio,
    required this.cantidadReq,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idTipo': idTipo,
      'idActividadServicio': idActividadServicio,
      'cantidadReq': cantidadReq,
    };
  }

  factory ItemActividadServicio.fromMap(Map<String, dynamic> map) {
    return ItemActividadServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idItem: int.tryParse(map['idItem']?.toString() ?? '') ?? 0,
      idTipo: int.tryParse(map['idTipo']?.toString() ?? '') ?? 0,
      idActividadServicio:
          int.tryParse(map['idActividadServicio']?.toString() ?? '') ?? 0,
      cantidadReq: double.tryParse(map['cantidadReq']?.toString() ?? '') ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'ItemActividadServicio{id: $id, idItem: $idItem, dTipo: $idTipo, idActividadServicio: $idActividadServicio, cantidadReq: $cantidadReq}';
  }
}
