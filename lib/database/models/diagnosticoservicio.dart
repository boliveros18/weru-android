class DiagnosticoServicio {
  final int? id;
  final int idServicio;
  final int idDiagnostico;

  DiagnosticoServicio({
    this.id,
    required this.idServicio,
    required this.idDiagnostico,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idDiagnostico': idDiagnostico,
    };
  }

  factory DiagnosticoServicio.fromMap(Map<String, dynamic> map) {
    return DiagnosticoServicio(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idServicio: int.tryParse(map['idServicio']?.toString() ?? '') ?? 0,
      idDiagnostico: int.tryParse(map['idDiagnostico']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'DiagnosticoServicio{id: $id, idServicio: $idServicio, idDiagnostico: $idDiagnostico}';
  }
}
