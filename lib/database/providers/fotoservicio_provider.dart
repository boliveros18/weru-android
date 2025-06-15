import 'package:sqflite/sqflite.dart';
import '../models/fotoservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class FotoServicioProvider {
  final Database db;
  FotoServicioProvider({required this.db});

  Future<void> insert(FotoServicio fotoservicio) async {
    await db.insert(
      'FotoServicio',
      fotoservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FotoServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'FotoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de FotoServicio no encontrado!');
    }
    return FotoServicio.fromMap(items.first);
  }

  Future<List<FotoServicio>> getAllByIdServicio(int idServicio) async {
    final List<Map<String, Object?>> maps = await db.query(
      'FotoServicio',
      where: 'idServicio = ?',
      whereArgs: [idServicio],
    );
    return maps.map((map) {
      return FotoServicio(
        id: map['id'] as int,
        idServicio: map['idServicio'] as int,
        archivo: map['archivo'] as String,
        comentario: map['comentario'] as String,
      );
    }).toList();
  }

  Future<void> update(FotoServicio fotoservicio) async {
    await db.update(
      'FotoServicio',
      fotoservicio.toMap(),
      where: 'id = ?',
      whereArgs: [fotoservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'FotoServicio',
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
      FotoServicio fotoservicio = FotoServicio(
        id: int.parse(parts[0].trim()),
        idServicio: int.parse(parts[1].trim()),
        archivo: parts[2].trim(),
        comentario: parts[3].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'FotoServicio',
          fotoservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
