class Indicador {
  final int id;
  final int idEstadoIndicador;
  final String descripcion;
  final double valorMin;
  final double valorMax;
  final String tipo;
  final String icono;

  Indicador({
    required this.id,
    required this.idEstadoIndicador,
    required this.descripcion,
    required this.valorMin,
    required this.valorMax,
    required this.tipo,
    required this.icono,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idEstadoIndicador': idEstadoIndicador,
      'descripcion': descripcion,
      'valorMin': valorMin,
      'valorMax': valorMax,
      'tipo': tipo,
      'icono': icono,
    };
  }

  factory Indicador.unknown() {
    return Indicador(
        id: 0,
        idEstadoIndicador: 0,
        descripcion: "Desconocido",
        valorMin: 0,
        valorMax: 0,
        tipo: "Desconocido",
        icono: "desconocido");
  }

  factory Indicador.fromMap(Map<String, dynamic> map) {
    return Indicador(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idEstadoIndicador:
          int.tryParse(map['idEstadoIndicador']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
      valorMin: double.tryParse(map['valorMin']?.toString() ?? '') ?? 0.0,
      valorMax: double.tryParse(map['valorMax']?.toString() ?? '') ?? 0.0,
      tipo: map['tipo']?.toString() ?? '',
      icono: map['icono']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Indicador{id: $id, idEstadoIndicador: $idEstadoIndicador, descripcion: $descripcion, valorMin: $valorMin, valorMax: $valorMax, tipo: $tipo, icono: $icono}';
  }
}
