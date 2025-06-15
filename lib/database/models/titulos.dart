class Titulos {
  final int id;
  final int idCampo;
  final String campo;
  final String valor;

  Titulos({
    required this.id,
    required this.idCampo,
    required this.campo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idCampo': idCampo,
      'campo': campo,
      'valor': valor,
    };
  }

   factory   Titulos.fromMap(Map<String, dynamic> map) {
    return   Titulos(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idCampo: int.tryParse(map['idCampo']?.toString() ?? '') ?? 0,
      campo: map['campo']?.toString() ?? '',
      valor: map['valor']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Titulos{id: $id, idCampo: $idCampo, campo: $campo, valor: $valor}';
  }
}
