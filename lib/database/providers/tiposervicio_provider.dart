import 'package:sqflite/sqflite.dart';
import '../models/tiposervicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class TipoServicioProvider {
  final Database db;
  TipoServicioProvider({required this.db});

  Future<void> insert(TipoServicio tiposervicio) async {
    await db.insert(
      'TipoServicio',
      tiposervicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TipoServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'TipoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      return TipoServicio(id: id, descripcion: "No especificado");
    }
    return TipoServicio.fromMap(items.first);
  }

  Future<List<TipoServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('TipoServicio');
    return maps.map((map) {
      return TipoServicio(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(TipoServicio tiposervicio) async {
    await db.update(
      'TipoServicio',
      tiposervicio.toMap(),
      where: 'id = ?',
      whereArgs: [tiposervicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'TipoServicio',
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
      TipoServicio tiposervicio = TipoServicio(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'TipoServicio',
          tiposervicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
