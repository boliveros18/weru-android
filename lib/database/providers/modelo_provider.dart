import 'package:sqflite/sqflite.dart';
import '../models/modelo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ModeloProvider {
  final Database db;
  ModeloProvider({required this.db});

  Future<void> insert(Modelo modelo) async {
    await db.insert(
      'Modelo',
      modelo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Modelo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Modelo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Modelo no encontrado!');
    }
    return Modelo.fromMap(items.first);
  }

  Future<List<Modelo>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Modelo');
    return maps.map((map) {
      return Modelo(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(Modelo modelo) async {
    await db.update(
      'Modelo',
      modelo.toMap(),
      where: 'id = ?',
      whereArgs: [modelo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Modelo',
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
      Modelo modelo = Modelo(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Modelo',
          modelo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
