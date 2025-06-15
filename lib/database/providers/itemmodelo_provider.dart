import 'package:sqflite/sqflite.dart';
import '../models/itemmodelo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ItemModeloProvider {
  final Database db;
  ItemModeloProvider({required this.db});

  Future<void> insert(ItemModelo itemmodelo) async {
    await db.insert(
      'ItemModelo',
      itemmodelo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ItemModelo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'ItemModelo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de ItemModelo no encontrado!');
    }
    return ItemModelo.fromMap(items.first);
  }

  Future<List<ItemModelo>> getAllByIdModelo(int idModelo) async {
    final List<Map<String, Object?>> maps = await db.query(
      'ItemModelo',
      where: 'idModelo = ?',
      whereArgs: [idModelo],
    );
    return maps.map((map) {
      return ItemModelo(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idModelo: map['idModelo'] as int,
      );
    }).toList();
  }

  Future<void> update(ItemModelo itemmodelo) async {
    await db.update(
      'ItemModelo',
      itemmodelo.toMap(),
      where: 'id = ?',
      whereArgs: [itemmodelo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ItemModelo',
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
      ItemModelo itemmodelo = ItemModelo(
        id: int.parse(parts[0].trim()),
        idItem: int.parse(parts[1].trim()),
        idModelo: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'ItemModelo',
          itemmodelo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
