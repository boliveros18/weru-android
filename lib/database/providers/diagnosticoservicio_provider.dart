import 'package:sqflite/sqflite.dart';
import '../models/diagnosticoservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class DiagnosticoServicioProvider {
  final Database db;
  DiagnosticoServicioProvider({required this.db});

  Future<void> insert(DiagnosticoServicio diagnosticoservicio) async {
    await db.insert(
      'DiagnosticoServicio',
      diagnosticoservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DiagnosticoServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'DiagnosticoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de DiagnosticoServicio no encontrado!');
    }
    return DiagnosticoServicio.fromMap(items.first);
  }

  Future<List<DiagnosticoServicio>> getAll() async {
    final List<Map<String, Object?>> maps =
        await db.query('DiagnosticoServicio');
    return maps.map((map) {
      return DiagnosticoServicio(
        id: map['id'] as int,
        idServicio: map['idServicio'] as int,
        idDiagnostico: map['idDiagnostico'] as int,
      );
    }).toList();
  }

  Future<List<DiagnosticoServicio>> getAllByIdServicio(int idServicio) async {
    final List<Map<String, Object?>> maps = await db.query(
      'DiagnosticoServicio',
      where: 'idServicio = ?',
      whereArgs: [idServicio],
    );
    return maps.map((map) {
      return DiagnosticoServicio(
        id: map['id'] as int,
        idServicio: map['idServicio'] as int,
        idDiagnostico: map['idDiagnostico'] as int,
      );
    }).toList();
  }

  Future<void> update(DiagnosticoServicio diagnosticoservicio) async {
    await db.update(
      'DiagnosticoServicio',
      diagnosticoservicio.toMap(),
      where: 'id = ?',
      whereArgs: [diagnosticoservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'DiagnosticoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByIdDiagnosticoAndIdServicio(
      int idDiagnostico, int idServicio) async {
    await db.delete(
      'DiagnosticoServicio',
      where: 'idDiagnostico = ? AND idServicio = ?',
      whereArgs: [idDiagnostico, idServicio],
    );
  }

  Future<void> insertInitFile(ArchiveFile file) async {
    List<int> bytes = file.content;
    String fileContent = utf8.decode(bytes);
    List<String> lines = fileContent.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      DiagnosticoServicio diagnosticoservicio = DiagnosticoServicio(
        id: int.parse(parts[0].trim()),
        idServicio: int.parse(parts[1].trim()),
        idDiagnostico: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'DiagnosticoServicio',
          diagnosticoservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
