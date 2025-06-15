class RegistroCamposAdicionales {
  final int id;
  final int idCamposAdicionales;
  final int idRegistro;
  final int? valor;
  final String nombre;

  RegistroCamposAdicionales({
    required this.id,
    required this.idCamposAdicionales,
    required this.idRegistro,
    this.valor,
    required this.nombre,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idCamposAdicionales': idCamposAdicionales,
      'idRegistro': idRegistro,
      'valor': valor,
      'nombre': nombre,
    };
  }

  factory RegistroCamposAdicionales.fromMap(Map<String, dynamic> map) {
    return RegistroCamposAdicionales(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idCamposAdicionales:
          int.tryParse(map['idCamposAdicionales']?.toString() ?? '') ?? 0,
      idRegistro: int.tryParse(map['idRegistro']?.toString() ?? '') ?? 0,
      valor: int.tryParse(map['valor']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'RegistroCamposAdicionales{id: $id, idCamposAdicionales: $idCamposAdicionales, idRegistro: $idRegistro, valor: $valor, nombre: $nombre}';
  }
}
