class ActividadModelo {
  final int id;
  final int idActividad;
  final int idModelo;

  ActividadModelo({
    required this.id,
    required this.idActividad,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idActividad': idActividad,
      'idModelo': idModelo,
    };
  }

   factory   ActividadModelo.fromMap(Map<String, dynamic> map) {
    return   ActividadModelo(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idActividad: int.tryParse(map['idActividad']?.toString() ?? '') ?? 0,
      idModelo: int.tryParse(map['idModelo']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'ActividadModelo{id: $id, idActividad: $idActividad, idModelo: $idModelo}';
  }
}
