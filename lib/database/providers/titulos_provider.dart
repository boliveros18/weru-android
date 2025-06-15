import 'package:sqflite/sqflite.dart';
import '../models/titulos.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class TitulosProvider {
  final Database db;
  TitulosProvider({required this.db});

  Future<void> insert(Titulos titulos) async {
    await db.insert(
      'Titulos',
      titulos.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Titulos> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Titulos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Titulos no encontrado!');
    }
    return Titulos.fromMap(items.first);
  }

  Future<List<Titulos>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Titulos');
    return maps.map((map) {
      return Titulos(
        id: map['id'] as int,
        idCampo: map['idCampo'] as int,
        campo: map['campo'] as String,
        valor: map['valor'] as String,
      );
    }).toList();
  }

  Future<void> update(Titulos titulos) async {
    await db.update(
      'Titulos',
      titulos.toMap(),
      where: 'id = ?',
      whereArgs: [titulos.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Titulos',
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
      Titulos titulos = Titulos(
        id: int.parse(parts[0].trim()),
        idCampo: int.parse(parts[1].trim()),
        campo: parts[2].trim(),
        valor: parts[3].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Titulos',
          titulos.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
