import 'package:sqflite/sqflite.dart';
import '../models/itemactividadservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ItemActividadServicioProvider {
  final Database db;
  ItemActividadServicioProvider({required this.db});

  Future<void> insert(ItemActividadServicio itemactividadservicio) async {
    await db.insert(
      'ItemActividadServicio',
      itemactividadservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ItemActividadServicio>> getItemsByIdActividadServicio(
      int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'ItemActividadServicio',
      where: 'idActividadServicio = ?',
      whereArgs: [id],
    );

    return items.map((map) => ItemActividadServicio.fromMap(map)).toList();
  }

  Future<List<ItemActividadServicio>> getAll() async {
    final List<Map<String, Object?>> maps =
        await db.query('ItemActividadServicio');
    return maps.map((map) {
      return ItemActividadServicio(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idTipo: map['idTipo'] as int,
        idActividadServicio: map['idActividadServicio'] as int,
        cantidadReq: map['cantidadReq'] as double,
      );
    }).toList();
  }

  Future<void> update(ItemActividadServicio itemactividadservicio) async {
    await db.update(
      'ItemActividadServicio',
      itemactividadservicio.toMap(),
      where: 'id = ?',
      whereArgs: [itemactividadservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ItemActividadServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertInitFile(ArchiveFile file) async {
    List<int> bytes = file.content;
    String fileContent = utf8.decode(bytes);
    List<String> lines = fileContent.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      ItemActividadServicio itemactividadservicio = ItemActividadServicio(
        id: int.parse(parts[0].trim()),
        idItem: int.parse(parts[1].trim()),
        idTipo: int.parse(parts[2].trim()),
        idActividadServicio: int.parse(parts[3].trim()),
        cantidadReq: double.parse(parts[4].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'ItemActividadServicio',
          itemactividadservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
