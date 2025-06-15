class Maletin {
  final int? id;
  final int idItem;
  final int idTecnico;
  final int cantidad;
  final double costo;
  final double valor;

  Maletin({
    this.id,
    required this.idItem,
    required this.idTecnico,
    required this.cantidad,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idTecnico': idTecnico,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
    };
  }

  factory Maletin.unknown() {
    return Maletin(
      id: 0,
      idItem: 0,
      idTecnico: 0,
      cantidad: 0,
      costo: 0,
      valor: 0,
    );
  }

  factory Maletin.fromMap(Map<String, dynamic> map) {
    return Maletin(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idItem: int.tryParse(map['idItem']?.toString() ?? '') ?? 0,
      idTecnico: int.tryParse(map['idTecnico']?.toString() ?? '') ?? 0,
      cantidad: int.tryParse(map['cantidad']?.toString() ?? '') ?? 0,
      costo: double.tryParse(map['costo']?.toString() ?? '') ?? 0.0,
      valor: double.tryParse(map['valor']?.toString() ?? '') ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Maletin{id: $id, idItem: $idItem, idTecnico: $idTecnico, cantidad: $cantidad, costo: $costo, valor: $valor}';
  }
}
