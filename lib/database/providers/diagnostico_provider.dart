import 'package:sqflite/sqflite.dart';
import '../models/diagnostico.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class DiagnosticoProvider {
  final Database db;
  DiagnosticoProvider({required this.db});

  Future<void> insert(Diagnostico diagnostico) async {
    await db.insert(
      'Diagnostico',
      diagnostico.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Diagnostico> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Diagnostico',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Diagnostico no encontrado!');
    }
    return Diagnostico.fromMap(items.first);
  }

  Future<List<Diagnostico>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Diagnostico');
    return maps.map((map) {
      return Diagnostico(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
        estado: map['estado'] as int,
      );
    }).toList();
  }

  Future<void> update(Diagnostico diagnostico) async {
    await db.update(
      'Diagnostico',
      diagnostico.toMap(),
      where: 'id = ?',
      whereArgs: [diagnostico.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Diagnostico',
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
      Diagnostico diagnostico = Diagnostico(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
        estado: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Diagnostico',
          diagnostico.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
