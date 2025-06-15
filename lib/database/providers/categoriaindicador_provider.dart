import 'package:sqflite/sqflite.dart';
import '../models/categoriaindicador.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class CategoriaIndicadorProvider {
  final Database db;
  CategoriaIndicadorProvider({required this.db});

  Future<void> insert(CategoriaIndicador categoriaindicador) async {
    await db.insert(
      'CategoriaIndicador',
      categoriaindicador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CategoriaIndicador> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'CategoriaIndicador',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de CategoriaIndicador no encontrado!');
    }
    return CategoriaIndicador.fromMap(items.first);
  }

  Future<List<CategoriaIndicador>> getAll() async {
    final List<Map<String, Object?>> maps =
        await db.query('CategoriaIndicador');
    return maps.map((map) {
      return CategoriaIndicador(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(CategoriaIndicador categoriaindicador) async {
    await db.update(
      'CategoriaIndicador',
      categoriaindicador.toMap(),
      where: 'id = ?',
      whereArgs: [categoriaindicador.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'CategoriaIndicador',
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
      CategoriaIndicador categoriaindicador = CategoriaIndicador(
        id: int.parse(parts[0].trim()),
        nombre: parts[1].trim(),
        descripcion: parts[2].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'CategoriaIndicador',
          categoriaindicador.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
