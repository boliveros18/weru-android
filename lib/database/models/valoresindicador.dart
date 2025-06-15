class ValoresIndicador {
  final int id;
  final int idIndicador;
  final String descripcion;

  ValoresIndicador({
    required this.id,
    required this.idIndicador,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'descripcion': descripcion,
    };
  }

   factory   ValoresIndicador.fromMap(Map<String, dynamic> map) {
    return   ValoresIndicador(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idIndicador: int.tryParse(map['idIndicador']?.toString() ?? '') ?? 0,
      descripcion: map['descripcion']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'ValoresIndicador{id: $id, idIndicador: $idIndicador, descripcion: $descripcion}';
  }
}
