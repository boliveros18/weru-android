import 'package:sqflite/sqflite.dart';
import '../models/indicadormodelo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndicadorModeloProvider {
  final Database db;
  IndicadorModeloProvider({required this.db});

  Future<void> insert(IndicadorModelo indicadormodelo) async {
    await db.insert(
      'IndicadorModelo',
      indicadormodelo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<IndicadorModelo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'IndicadorModelo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de IndicadorModelo no encontrado!');
    }
    return IndicadorModelo.fromMap(items.first);
  }

  Future<List<IndicadorModelo>> getAllByIdModelo(int idModelo) async {
    final List<Map<String, Object?>> maps = await db.query(
      'IndicadorModelo',
      where: 'idModelo = ?',
      whereArgs: [idModelo],
    );
    return maps.map((map) {
      return IndicadorModelo(
        id: map['id'] as int,
        idIndicador: map['idIndicador'] as int,
        idModelo: map['idModelo'] as int,
      );
    }).toList();
  }

  Future<void> update(IndicadorModelo indicadormodelo) async {
    await db.update(
      'IndicadorModelo',
      indicadormodelo.toMap(),
      where: 'id = ?',
      whereArgs: [indicadormodelo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'IndicadorModelo',
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
      IndicadorModelo indicadormodelo = IndicadorModelo(
        id: int.parse(parts[0].trim()),
        idIndicador: int.parse(parts[1].trim()),
        idModelo: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'IndicadorModelo',
          indicadormodelo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
