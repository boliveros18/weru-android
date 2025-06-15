class IndicadorServicio {
  final int? id;
  final int idIndicador;
  final int idServicio;
  final int idTecnico;
  final String valor;

  IndicadorServicio({
    this.id,
    required this.idIndicador,
    required this.idServicio,
    required this.idTecnico,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'idServicio': idServicio,
      'idTecnico': idTecnico,
      'valor': valor,
    };
  }

  factory IndicadorServicio.unknown() {
    return IndicadorServicio(
      id: 0,
      idIndicador: 0,
      idServicio: 0,
      idTecnico: 0,
      valor: "Desconocido",
    );
  }

  factory IndicadorServicio.fromMap(Map<String, dynamic> map) {
    return IndicadorServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idIndicador: int.tryParse(map['idIndicador']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      idTecnico: int.tryParse(map['idTecnico']?.toString() ?? '') ?? 0,
      valor: map['valor']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'IndicadorServicio{id: $id, idIndicador: $idIndicador, idServicio: $idServicio, idTecnico: $idTecnico, valor: $valor}';
  }
}
