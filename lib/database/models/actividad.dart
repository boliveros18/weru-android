class Actividad {
  final int id;
  final String codigoExt;
  final String descripcion;
  final int costo;
  final int valor;
  final int idEstadoActividad;

  Actividad({
    required this.id,
    required this.codigoExt,
    required this.descripcion,
    required this.costo,
    required this.valor,
    required this.idEstadoActividad,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'codigoExt': codigoExt,
      'descripcion': descripcion,
      'costo': costo,
      'valor': valor,
      'idEstadoActividad': idEstadoActividad,
    };
  }

  factory Actividad.unknown() {
    return Actividad(
      id: 0,
      codigoExt: "Desconocido",
      descripcion: 'Desconocido',
      costo: 0,
      valor: 0,
      idEstadoActividad: 0,
    );
  }

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      codigoExt: map['codigoExt']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
      idEstadoActividad:
          int.tryParse(map['idEstadoActividad']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Actividad{id: $id, codigoExt: $codigoExt, descripcion: $descripcion, costo: $costo, valor: $valor, idEstadoActividad: $idEstadoActividad}';
  }
}
