class TipoCliente {
  final int id;
  final String nombre;
  final String descripcion;

  TipoCliente({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

   factory   TipoCliente.fromMap(Map<String, dynamic> map) {
    return   TipoCliente(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'TipoCliente{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
