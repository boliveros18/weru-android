import 'package:sqflite/sqflite.dart';
import '../models/indicadorservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndicadorServicioProvider {
  final Database db;
  IndicadorServicioProvider({required this.db});

  Future<void> insert(IndicadorServicio indicadorservicio) async {
    await db.insert(
      'IndicadorServicio',
      indicadorservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<IndicadorServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'IndicadorServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de IndicadorServicio no encontrado!');
    }
    return IndicadorServicio.fromMap(items.first);
  }

  Future<List<IndicadorServicio>> getAllByIdServicio(
      int idServicio, int idTecnico) async {
    final List<Map<String, Object?>> maps = await db.query(
      'IndicadorServicio',
      where: 'idServicio = ? AND idTecnico = ?',
      whereArgs: [idServicio, idTecnico],
    );
    return maps.map((map) {
      return IndicadorServicio(
        id: map['id'] as int,
        idIndicador: map['idIndicador'] as int,
        idServicio: map['idServicio'] as int,
        idTecnico: map['idTecnico'] as int,
        valor: map['valor'] as String,
      );
    }).toList();
  }

  Future<void> update(IndicadorServicio indicadorservicio) async {
    await db.update(
      'IndicadorServicio',
      indicadorservicio.toMap(),
      where: 'id = ?',
      whereArgs: [indicadorservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'IndicadorServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByIdIndicador(
      int idIndicador, int idServicio, int idTecnico) async {
    await db.delete(
      'IndicadorServicio',
      where: 'idIndicador = ?  AND idServicio = ? AND idTecnico = ?',
      whereArgs: [idIndicador, idServicio, idTecnico],
    );
  }

  Future<void> insertInitFile(ArchiveFile file) async {
    List<int> bytes = file.content;
    String fileContent = utf8.decode(bytes);
    List<String> lines = fileContent.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      IndicadorServicio indicadorservicio = IndicadorServicio(
        id: int.parse(parts[0].trim()),
        idIndicador: int.parse(parts[1].trim()),
        idServicio: int.parse(parts[2].trim()),
        idTecnico: int.parse(parts[3].trim()),
        valor: parts[4].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'IndicadorServicio',
          indicadorservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
