class Tecnico {
  final int id;
  final String cedula;
  final String nombre;
  final int idProveedor;
  final int idEstadoTecnico;
  final String usuario;
  final String clave;
  final String telefono;
  final String celular;
  final double latitud;
  final double longitud;
  final String androidID;
  final String fechaPulso;
  final String versionApp;
  final String situacionActual;

  Tecnico(
      {required this.id,
      required this.cedula,
      required this.nombre,
      required this.idProveedor,
      required this.idEstadoTecnico,
      required this.usuario,
      required this.clave,
      required this.telefono,
      required this.celular,
      required this.latitud,
      required this.longitud,
      required this.androidID,
      required this.fechaPulso,
      required this.versionApp,
      required this.situacionActual});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombre': nombre,
      'idProveedor': idProveedor,
      'idEstadoTecnico': idEstadoTecnico,
      'usuario': usuario,
      'clave': clave,
      'telefono': telefono,
      'celular': celular,
      'latitud': latitud,
      'longitud': longitud,
      'androidID': androidID,
      'fechaPulso': fechaPulso,
      'versionApp': versionApp,
      'situacionActual': situacionActual
    };
  }

  factory Tecnico.fromMap(Map<String, dynamic> map) {
    return Tecnico(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      cedula: map['cedula']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      idProveedor: int.tryParse(map['idProveedor']?.toString() ?? '') ?? 0,
      idEstadoTecnico:
          int.tryParse(map['idEstadoTecnico']?.toString() ?? '') ?? 0,
      usuario: map['usuario']?.toString() ?? '',
      clave: map['clave']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      celular: map['celular']?.toString() ?? '',
      latitud: double.tryParse(map['latitud']?.toString() ?? '') ?? 0.0,
      longitud: double.tryParse(map['longitud']?.toString() ?? '') ?? 0.0,
      androidID: map['androidID']?.toString() ?? '',
      fechaPulso: map['fechaPulso']?.toString() ?? '',
      versionApp: map['versionApp']?.toString() ?? '',
      situacionActual: map['situacionActual']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Tecnico{id: $id, cedula: $cedula, nombre: $nombre, idProveedor: $idProveedor, idEstadoTecnico: $idEstadoTecnico, usuario: $usuario, clave: $clave, telefono: $telefono, celular: $celular, latitud: $latitud, longitud: $longitud, androidID: $androidID, fechaPulso: $fechaPulso, versionApp: $versionApp, situacionActual: $situacionActual}';
  }
}
