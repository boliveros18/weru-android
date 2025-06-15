class ItemModelo {
  final int id;
  final int idItem;
  final int idModelo;

  ItemModelo({
    required this.id,
    required this.idItem,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idModelo': idModelo,
    };
  }

   factory   ItemModelo.fromMap(Map<String, dynamic> map) {
    return   ItemModelo(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      idItem: int.tryParse(map['idItem']?.toString() ?? '') ?? 0,
      idModelo: int.tryParse(map['idModelo']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'ItemModelo{id: $id, idItem: $idItem, idModelo: $idModelo}';
  }
}
