class TipoItem {
  final int id;
  final String descripcion;

  TipoItem({
    required this.id,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

   factory   TipoItem.fromMap(Map<String, dynamic> map) {
    return   TipoItem(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'TipoItem{id: $id, descripcion: $descripcion}';
  }
}
