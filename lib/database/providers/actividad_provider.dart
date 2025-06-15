import 'package:sqflite/sqflite.dart';
import '../models/actividad.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ActividadProvider {
  final Database db;
  ActividadProvider({required this.db});

  Future<void> insert(Actividad actividad) async {
    await db.insert(
      'Actividad',
      actividad.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Actividad> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Actividad',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Actividad no encontrado!');
    }
    return Actividad.fromMap(items.first);
  }

  Future<List<Actividad>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Actividad');
    return maps.map((map) {
      return Actividad(
        id: map['id'] as int,
        codigoExt: map['codigoExt'] as String,
        descripcion: map['descripcion'] as String,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
        idEstadoActividad: map['idEstadoActividad'] as int,
      );
    }).toList();
  }

  Future<void> update(Actividad actividad) async {
    await db.update(
      'Actividad',
      actividad.toMap(),
      where: 'id = ?',
      whereArgs: [actividad.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Actividad',
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
      Actividad actividad = Actividad(
        id: int.parse(parts[0].trim()),
        codigoExt: parts[1].trim(),
        descripcion: parts[2].trim(),
        costo: int.parse(parts[3].trim()),
        valor: int.parse(parts[4].trim()),
        idEstadoActividad: int.parse(parts[5].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Actividad',
          actividad.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
