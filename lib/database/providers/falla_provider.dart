import 'package:sqflite/sqflite.dart';
import '../models/falla.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class FallaProvider {
  final Database db;
  FallaProvider({required this.db});

  Future<void> insert(Falla falla) async {
    await db.insert(
      'Falla',
      falla.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Falla> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Falla',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      return Falla(id: id, descripcion: "No especificado", estado: 1);
    }
    return Falla.fromMap(items.first);
  }

  Future<List<Falla>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Falla');
    return maps.map((map) {
      return Falla(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
        estado: map['estado'] as int,
      );
    }).toList();
  }

  Future<void> update(Falla falla) async {
    await db.update(
      'Falla',
      falla.toMap(),
      where: 'id = ?',
      whereArgs: [falla.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Falla',
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
      Falla falla = Falla(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
        estado: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Falla',
          falla.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
