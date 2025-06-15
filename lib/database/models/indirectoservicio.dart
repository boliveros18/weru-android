class IndirectoServicio {
  final int? id;
  final int idIndirecto;
  final int idServicio;
  final int cantidad;
  final int costo;
  final int valor;

  IndirectoServicio({
    this.id,
    required this.idIndirecto,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndirecto': idIndirecto,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
    };
  }

  factory IndirectoServicio.unknown() {
    return IndirectoServicio(
      id: 0,
      idIndirecto: 0,
      idServicio: 0,
      cantidad: 0,
      costo: 0,
      valor: 0,
    );
  }

  factory IndirectoServicio.fromMap(Map<String, dynamic> map) {
    return IndirectoServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idIndirecto: int.tryParse(map['idIndirecto']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      cantidad: int.tryParse(map['cantidad']?.toString() ?? '') ?? 0,
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'IndirectoServicio{id: $id, idIndirecto: $idIndirecto, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor}';
  }
}
