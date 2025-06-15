class Indirecto {
  final int id;
  final int idEstado;
  final String descripcion;
  final int costo;
  final int valor;

  Indirecto({
    required this.id,
    required this.idEstado,
    required this.descripcion,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idEstado': idEstado,
      'descripcion': descripcion,
      'costo': costo,
      'valor': valor,
    };
  }

  factory Indirecto.unknown() {
    return Indirecto(
      id: 0,
      idEstado: 0,
      descripcion: "Desconocido",
      costo: 0,
      valor: 0,
    );
  }

  factory Indirecto.fromMap(Map<String, dynamic> map) {
    return Indirecto(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idEstado: int.tryParse(map['idEstado']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Indirecto{id: $id, idEstado: $idEstado, descripcion: $descripcion, costo: $costo, valor: $valor}';
  }
}
