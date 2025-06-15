class ItemServicio {
  final int? id;
  final int idItem;
  final int idServicio;
  final double cantidad;
  final int costo;
  final int valor;
  final double cantidadReq;
  final String fechaUltimaVez;
  final String vidaUtil;

  ItemServicio({
    this.id,
    required this.idItem,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
    required this.cantidadReq,
    required this.fechaUltimaVez,
    required this.vidaUtil,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
      'cantidadReq': cantidadReq,
      'fechaUltimaVez': fechaUltimaVez,
      'vidaUtil': vidaUtil,
    };
  }

  factory ItemServicio.unknown() {
    return ItemServicio(
        id: 0,
        idItem: 0,
        idServicio: 0,
        cantidad: 0,
        costo: 0,
        valor: 0,
        cantidadReq: 0,
        fechaUltimaVez: "desconocido",
        vidaUtil: "desconocido");
  }

  factory ItemServicio.fromMap(Map<String, dynamic> map) {
    return ItemServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idItem: int.tryParse(map['idItem']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      cantidad: double.tryParse(map['cantidad']?.toString() ?? '') ?? 0.0,
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
      cantidadReq: double.tryParse(map['cantidadReq']?.toString() ?? '') ?? 0.0,
      fechaUltimaVez: map['fechaUltimaVez']?.toString() ?? '',
      vidaUtil: map['vidaUtil']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'ItemServicio{id: $id, idItem: $idItem, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor, cantidadReq: $cantidadReq, fechaUltimaVez: $fechaUltimaVez, vidaUtil: $vidaUtil}';
  }
}
