import 'package:sqflite/sqflite.dart';
import '../models/novedad.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class NovedadProvider {
  final Database db;
  NovedadProvider({required this.db});

  Future<void> insert(Novedad novedad) async {
    await db.insert(
      'Novedad',
      novedad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Novedad> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Novedad',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Novedad no encontrado!');
    }
    return Novedad.fromMap(items.first);
  }

  Future<List<Novedad>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Novedad');
    return maps.map((map) {
      return Novedad(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
        estado: map['estado'] as int,
      );
    }).toList();
  }

  Future<void> update(Novedad novedad) async {
    await db.update(
      'Novedad',
      novedad.toMap(),
      where: 'id = ?',
      whereArgs: [novedad.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Novedad',
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
      Novedad novedad = Novedad(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
        estado: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Novedad',
          novedad.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
