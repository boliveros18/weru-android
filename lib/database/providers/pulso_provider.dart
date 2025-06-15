import 'package:sqflite/sqflite.dart';
import '../models/pulso.dart';

class PulsoProvider {
  final Database db;
  PulsoProvider({required this.db});

  Future<Pulso> insert(Pulso pulso) async {
    final int id = await db.insert(
      'Pulso',
      pulso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    pulso.id = id;
    return pulso;
  }

  Future<Pulso> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Pulso',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Pulso no encontrado!');
    }
    return Pulso.fromMap(items.first);
  }

  Future<List<Pulso>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Pulso');
    return maps.map((map) {
      return Pulso.fromMap(map);
    }).toList();
  }

  Future<void> update(Pulso pulso) async {
    await db.update(
      'Pulso',
      pulso.toMap(),
      where: 'id = ?',
      whereArgs: [pulso.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Pulso',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
