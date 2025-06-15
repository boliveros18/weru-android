import 'package:sqflite/sqflite.dart';
import '../models/itemservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ItemServicioProvider {
  final Database db;
  ItemServicioProvider({required this.db});

  Future<void> insert(ItemServicio itemservicio) async {
    await db.insert(
      'ItemServicio',
      itemservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ItemServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'ItemServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de ItemServicio no encontrado!');
    }
    return ItemServicio.fromMap(items.first);
  }

  Future<List<ItemServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('ItemServicio');
    return maps.map((map) {
      return ItemServicio(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idServicio: map['idServicio'] as int,
        cantidad: map['cantidad'] as double,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
        cantidadReq: map['cantidadReq'] as double,
        fechaUltimaVez: map['fechaUltimaVez'] as String,
        vidaUtil: map['vidaUtil'] as String,
      );
    }).toList();
  }

  Future<List<ItemServicio>> getAllByIdServicio(int idServicio) async {
    final List<Map<String, Object?>> maps = await db.query(
      'ItemServicio',
      where: 'idServicio = ?',
      whereArgs: [idServicio],
    );
    return maps.map((map) {
      return ItemServicio(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idServicio: map['idServicio'] as int,
        cantidad: map['cantidad'] as double,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
        cantidadReq: map['cantidadReq'] as double,
        fechaUltimaVez: map['fechaUltimaVez'] as String,
        vidaUtil: map['vidaUtil'] as String,
      );
    }).toList();
  }

  Future<void> update(ItemServicio itemservicio) async {
    await db.update(
      'ItemServicio',
      itemservicio.toMap(),
      where: 'id = ?',
      whereArgs: [itemservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ItemServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByIdItemAndIdServicio(int idItem, int idServicio) async {
    await db.delete(
      'ItemServicio',
      where: 'idItem = ? AND idServicio = ?',
      whereArgs: [idItem, idServicio],
    );
  }

  Future<void> insertInitFile(ArchiveFile file) async {
    List<int> bytes = file.content;
    String fileContent = utf8.decode(bytes);
    List<String> lines = fileContent.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      ItemServicio itemservicio = ItemServicio(
        id: int.parse(parts[0].trim()),
        idItem: int.parse(parts[1].trim()),
        idServicio: int.parse(parts[2].trim()),
        cantidad: double.parse(parts[3].trim()),
        costo: int.parse(parts[4].trim()),
        valor: int.parse(parts[5].trim()),
        cantidadReq: double.parse(parts[6].trim()),
        fechaUltimaVez: parts[7].trim(),
        vidaUtil: parts[8].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'ItemServicio',
          itemservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
