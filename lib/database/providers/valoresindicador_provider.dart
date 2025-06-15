import 'package:sqflite/sqflite.dart';
import '../models/valoresindicador.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ValoresIndicadorProvider {
  final Database db;
  ValoresIndicadorProvider({required this.db});

  Future<void> insert(ValoresIndicador valoresindicador) async {
    await db.insert(
      'ValoresIndicador',
      valoresindicador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ValoresIndicador> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'ValoresIndicador',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de ValoresIndicador no encontrado!');
    }
    return ValoresIndicador.fromMap(items.first);
  }

  Future<List<ValoresIndicador>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('ValoresIndicador');
    return maps.map((map) {
      return ValoresIndicador(
        id: map['id'] as int,
        idIndicador: map['idIndicador'] as int,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(ValoresIndicador valoresindicador) async {
    await db.update(
      'ValoresIndicador',
      valoresindicador.toMap(),
      where: 'id = ?',
      whereArgs: [valoresindicador.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ValoresIndicador',
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
      ValoresIndicador valoresindicador = ValoresIndicador(
        id: int.parse(parts[0].trim()),
        idIndicador: int.parse(parts[1].trim()),
        descripcion: parts[2].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'ValoresIndicador',
          valoresindicador.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
