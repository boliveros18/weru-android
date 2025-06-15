class Cliente {
  final int id;
  final String nombre;
  final String direccion;
  final int idCiudad;
  final String telefono;
  final String celular;
  final int idTipoCliente;
  final int idTipoDocumento;
  final String numDocumento;
  final String establecimiento;
  final String contacto;
  final int idEstado;
  final String correo;

  Cliente({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.idCiudad,
    required this.telefono,
    required this.celular,
    required this.idTipoCliente,
    required this.idTipoDocumento,
    required this.numDocumento,
    required this.establecimiento,
    required this.contacto,
    required this.idEstado,
    required this.correo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'idCiudad': idCiudad,
      'telefono': telefono,
      'celular': celular,
      'idTipoCliente': idTipoCliente,
      'idTipoDocumento': idTipoDocumento,
      'numDocumento': numDocumento,
      'establecimiento': establecimiento,
      'contacto': contacto,
      'idEstado': idEstado,
      'correo': correo,
    };
  }

  factory Cliente.unknown() {
    return Cliente(
      id: 0,
      nombre: 'Desconocido',
      direccion: 'N/A',
      idCiudad: 0,
      telefono: 'N/A',
      celular: 'N/A',
      idTipoCliente: 0,
      idTipoDocumento: 0,
      numDocumento: 'N/A',
      establecimiento: 'N/A',
      contacto: 'N/A',
      idEstado: 0,
      correo: 'N/A',
    );
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      direccion: map['direccion']?.toString() ?? '',
      idCiudad: int.tryParse(map['idCiudad']?.toString() ?? '') ?? 0,
      telefono: map['telefono']?.toString() ?? '',
      celular: map['celular']?.toString() ?? '',
      idTipoCliente: int.tryParse(map['idTipoCliente']?.toString() ?? '') ?? 0,
      idTipoDocumento:
          int.tryParse(map['idTipoDocumento']?.toString() ?? '') ?? 0,
      numDocumento: map['numDocumento']?.toString() ?? '',
      establecimiento: map['establecimiento']?.toString() ?? '',
      contacto: map['contacto']?.toString() ?? '',
      idEstado: int.tryParse(map['idEstado']?.toString() ?? '') ?? 0,
      correo: map['correo']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nombre: $nombre, direccion: $direccion, idCiudad: $idCiudad, telefono: $telefono, celular: $celular, idTipoCliente: $idTipoCliente, idTipoDocumento: $idTipoDocumento, numDocumento: $numDocumento, establecimiento: $establecimiento, contacto: $contacto, idEstado: $idEstado, correo: $correo}';
  }
}
