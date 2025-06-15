class IndicadorModelo {
  final int id;
  final int idIndicador;
  final int idModelo;

  IndicadorModelo({
    required this.id,
    required this.idIndicador,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'idModelo': idModelo,
    };
  }

   factory   IndicadorModelo.fromMap(Map<String, dynamic> map) {
    return   IndicadorModelo(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idIndicador: int.tryParse(map['idIndicador']?.toString() ?? '') ?? 0,
      idModelo: int.tryParse(map['idModelo']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'IndicadorModelo{id: $id, idIndicador: $idIndicador, idModelo: $idModelo}';
  }
}
