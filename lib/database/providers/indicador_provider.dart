import 'package:sqflite/sqflite.dart';
import '../models/indicador.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndicadorProvider {
  final Database db;
  IndicadorProvider({required this.db});

  Future<void> insert(Indicador indicador) async {
    await db.insert(
      'Indicador',
      indicador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Indicador> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Indicador',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Indicador no encontrado!');
    }
    return Indicador.fromMap(items.first);
  }

  Future<List<Indicador>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Indicador');
    return maps.map((map) {
      return Indicador(
        id: map['id'] as int,
        idEstadoIndicador: map['idEstadoIndicador'] as int,
        descripcion: map['descripcion'] as String,
        valorMin: (map['valorMin'] as num).toDouble(),
        valorMax: (map['valorMax'] as num).toDouble(),
        tipo: map['tipo'] as String,
        icono: map['icono'] as String,
      );
    }).toList();
  }

  Future<void> update(Indicador indicador) async {
    await db.update(
      'Indicador',
      indicador.toMap(),
      where: 'id = ?',
      whereArgs: [indicador.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Indicador',
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
      Indicador indicador = Indicador(
        id: int.parse(parts[0].trim()),
        idEstadoIndicador: int.parse(parts[1].trim()),
        descripcion: parts[2].trim(),
        valorMin: double.parse(parts[3].trim()),
        valorMax: double.parse(parts[4].trim()),
        tipo: parts[5].trim(),
        icono: parts[6].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Indicador',
          indicador.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
