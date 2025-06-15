class Equipo {
  final int id;
  final String serial;
  final String nombre;
  final String fechaCompra;
  final String fechaGarantia;
  final int idModelo;
  final int idEstadoEquipo;
  final int idProveedor;
  final int idCliente;

  Equipo({
    required this.id,
    required this.serial,
    required this.nombre,
    required this.fechaCompra,
    required this.fechaGarantia,
    required this.idModelo,
    required this.idEstadoEquipo,
    required this.idProveedor,
    required this.idCliente,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'serial': serial,
      'nombre': nombre,
      'fechaCompra': fechaCompra,
      'fechaGarantia': fechaGarantia,
      'idModelo': idModelo,
      'idEstadoEquipo': idEstadoEquipo,
      'idProveedor': idProveedor,
      'idCliente': idCliente,
    };
  }

  factory Equipo.unknown() {
    return Equipo(
      id: 0,
      serial: 'N/A',
      nombre: 'Desconocido',
      fechaCompra: 'N/A',
      fechaGarantia: 'N/A',
      idModelo: 0,
      idEstadoEquipo: 0,
      idProveedor: 0,
      idCliente: 0,
    );
  }

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      serial: map['serial']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      fechaCompra: map['fechaCompra']?.toString() ?? '',
      fechaGarantia: map['fechaGarantia']?.toString() ?? '',
      idModelo: int.tryParse(map['idModelo']?.toString() ?? '') ?? 0,
      idEstadoEquipo:
          int.tryParse(map['idEstadoEquipo']?.toString() ?? '') ?? 0,
      idProveedor: int.tryParse(map['idProveedor']?.toString() ?? '') ?? 0,
      idCliente: int.tryParse(map['idCliente']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'Equipo{id: $id, serial: $serial, nombre: $nombre, fechaCompra: $fechaCompra, fechaGarantia: $fechaGarantia, idModelo: $idModelo, idEstadoEquipo: $idEstadoEquipo, idProveedor: $idProveedor, idCliente: $idCliente}';
  }
}
