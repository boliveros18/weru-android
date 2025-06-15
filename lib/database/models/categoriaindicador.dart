class CategoriaIndicador {
  final int id;
  final String nombre;
  final String descripcion;

  CategoriaIndicador({
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

   factory   CategoriaIndicador.fromMap(Map<String, dynamic> map) {
    return   CategoriaIndicador(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'CategoriaIndicador{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
