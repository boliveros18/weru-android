import 'package:sqflite/sqflite.dart';
import '../models/estadoservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class EstadoServicioProvider {
  final Database db;
  EstadoServicioProvider({required this.db});

  Future<void> insert(EstadoServicio estadoservicio) async {
    await db.insert(
      'EstadoServicio',
      estadoservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EstadoServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'EstadoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de EstadoServicio no encontrado!');
    }
    return EstadoServicio.fromMap(items.first);
  }

  Future<List<EstadoServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('EstadoServicio');
    return maps.map((map) {
      return EstadoServicio(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(EstadoServicio estadoservicio) async {
    await db.update(
      'EstadoServicio',
      estadoservicio.toMap(),
      where: 'id = ?',
      whereArgs: [estadoservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'EstadoServicio',
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
      EstadoServicio estadoservicio = EstadoServicio(
        id: int.parse(parts[0].trim()),
        nombre: parts[1].trim(),
        descripcion: parts[2].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'EstadoServicio',
          estadoservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
