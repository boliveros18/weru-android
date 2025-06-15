class IndirectoModelo {
  final int id;
  final int idIndirecto;
  final int idModelo;

  IndirectoModelo({
    required this.id,
    required this.idIndirecto,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndirecto': idIndirecto,
      'idModelo': idModelo,
    };
  }

   factory   IndirectoModelo.fromMap(Map<String, dynamic> map) {
    return   IndirectoModelo(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idIndirecto: int.tryParse(map['idIndirecto']?.toString() ?? '') ?? 0,
      idModelo: int.tryParse(map['idModelo']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'IndirectoModelo{id: $id, idIndirecto: $idIndirecto, idModelo: $idModelo}';
  }
}
