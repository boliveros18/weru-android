class Pulso {
  int? id;
  final int idTecnico;
  final double latitud;
  final double longitud;
  final String fechaPulso;
  final String situacionActual;

  Pulso(
      {this.id,
      required this.idTecnico,
      required this.latitud,
      required this.longitud,
      required this.fechaPulso,
      required this.situacionActual});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idTecnico': idTecnico,
      'latitud': latitud,
      'longitud': longitud,
      'fechaPulso': fechaPulso,
      'situacionActual': situacionActual,
    };
  }

  factory Pulso.fromMap(Map<String, dynamic> map) {
    return Pulso(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idTecnico: int.tryParse(map['idTecnico']?.toString() ?? '') ?? 0,
      latitud: double.tryParse(map['latitud']?.toString() ?? '') ?? 0.0,
      longitud: double.tryParse(map['longitud']?.toString() ?? '') ?? 0.0,
      fechaPulso: map['fechaPulso']?.toString() ?? '',
      situacionActual: map['situacionActual']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Pulso{id: $id, idTecnico: $idTecnico, latitud: $latitud, longitud: $longitud, fechaPulso: $fechaPulso situacionActual: $situacionActual} ';
  }
}
