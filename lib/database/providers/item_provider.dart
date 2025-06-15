import 'package:sqflite/sqflite.dart';
import '../models/item.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ItemProvider {
  final Database db;
  ItemProvider({required this.db});

  Future<void> insert(Item item) async {
    await db.insert(
      'Item',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Item> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Item',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Item no encontrado!');
    }
    return Item.fromMap(items.first);
  }

  Future<List<Item>> getAllByType(int type) async {
    final List<Map<String, Object?>> maps = await db.query(
      'Item',
      where: 'tipo = ?',
      whereArgs: [type],
    );
    return maps.map((map) {
      return Item(
        id: map['id'] as int,
        SKU: map['SKU'] as String,
        descripcion: map['descripcion'] as String,
        tipo: map['tipo'] as int,
        costo: map['costo'] as int,
        precio: map['precio'] as int,
        idEstadoItem: map['idEstadoItem'] as int,
        foto: map['foto'] as String,
      );
    }).toList();
  }

  Future<void> update(Item item) async {
    await db.update(
      'Item',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Item',
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
      Item item = Item(
        id: int.parse(parts[0].trim()),
        SKU: parts[1].trim(),
        descripcion: parts[2].trim(),
        tipo: int.parse(parts[3].trim()),
        costo: int.parse(parts[4].trim()),
        precio: int.parse(parts[5].trim()),
        idEstadoItem: int.parse(parts[6].trim()),
        foto: parts[7].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Item',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
