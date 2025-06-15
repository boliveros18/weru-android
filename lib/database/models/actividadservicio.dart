class ActividadServicio {
  final int? id;
  final int idActividad;
  final int idServicio;
  final int cantidad;
  final int costo;
  final int valor;
  final int ejecutada;

  ActividadServicio({
    this.id,
    required this.idActividad,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
    required this.ejecutada,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idActividad': idActividad,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
      'ejecutada': ejecutada,
    };
  }

  factory ActividadServicio.unknown() {
    return ActividadServicio(
      id: 0,
      idActividad: 0,
      idServicio: 0,
      cantidad: 0,
      costo: 0,
      valor: 0,
      ejecutada: 0,
    );
  }

  factory ActividadServicio.fromMap(Map<String, dynamic> map) {
    return ActividadServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idActividad: int.tryParse(map['idActividad']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      cantidad: int.tryParse(map['cantidad']?.toString() ?? '') ?? 0,
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
      ejecutada: int.tryParse(map['ejecutada']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'ActividadServicio{id: $id, idActividad: $idActividad, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor, ejecutada: $ejecutada}';
  }
}
