import 'package:sqflite/sqflite.dart';
import '../models/actividadmodelo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ActividadModeloProvider {
  final Database db;
  ActividadModeloProvider({required this.db});

  Future<void> insert(ActividadModelo actividadmodelo) async {
    await db.insert(
      'ActividadModelo',
      actividadmodelo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ActividadModelo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'ActividadModelo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de ActividadModelo no encontrado!');
    }
    return ActividadModelo.fromMap(items.first);
  }

  Future<List<ActividadModelo>> getAllByIdModelo(int idModelo) async {
    final List<Map<String, Object?>> maps = await db.query(
      'ActividadModelo',
      where: 'idModelo = ?',
      whereArgs: [idModelo],
    );

    return maps.map((map) {
      return ActividadModelo(
        id: map['id'] as int,
        idActividad: map['idActividad'] as int,
        idModelo: map['idModelo'] as int,
      );
    }).toList();
  }

  Future<void> update(ActividadModelo actividadmodelo) async {
    await db.update(
      'ActividadModelo',
      actividadmodelo.toMap(),
      where: 'id = ?',
      whereArgs: [actividadmodelo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ActividadModelo',
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
      ActividadModelo actividadmodelo = ActividadModelo(
        id: int.parse(parts[0].trim()),
        idActividad: int.parse(parts[1].trim()),
        idModelo: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'ActividadModelo',
          actividadmodelo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
