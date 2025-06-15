import 'package:sqflite/sqflite.dart';
import '../models/ciudad.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class CiudadProvider {
  final Database db;
  CiudadProvider({required this.db});

  Future<void> insert(Ciudad ciudad) async {
    await db.insert(
      'Ciudad',
      ciudad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Ciudad> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Ciudad',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Ciudad no encontrado!');
    }
    return Ciudad.fromMap(items.first);
  }

  Future<List<Ciudad>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Ciudad');
    return maps.map((map) {
      return Ciudad(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        estado: map['estado'] as int,
      );
    }).toList();
  }

  Future<void> update(Ciudad ciudad) async {
    await db.update(
      'Ciudad',
      ciudad.toMap(),
      where: 'id = ?',
      whereArgs: [ciudad.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Ciudad',
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
      Ciudad ciudad = Ciudad(
        id: int.parse(parts[0].trim()),
        nombre: parts[1].trim(),
        estado: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Ciudad',
          ciudad.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
