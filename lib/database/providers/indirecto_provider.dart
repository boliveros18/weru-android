import 'package:sqflite/sqflite.dart';
import '../models/indirecto.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndirectoProvider {
  final Database db;
  IndirectoProvider({required this.db});

  Future<void> insert(Indirecto indirecto) async {
    await db.insert(
      'Indirecto',
      indirecto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Indirecto> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Indirecto',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Indirecto no encontrado!');
    }
    return Indirecto.fromMap(items.first);
  }

  Future<List<Indirecto>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Indirecto');
    return maps.map((map) {
      return Indirecto(
        id: map['id'] as int,
        idEstado: map['idEstado'] as int,
        descripcion: map['descripcion'] as String,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
      );
    }).toList();
  }

  Future<void> update(Indirecto indirecto) async {
    await db.update(
      'Indirecto',
      indirecto.toMap(),
      where: 'id = ?',
      whereArgs: [indirecto.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Indirecto',
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
      Indirecto indirecto = Indirecto(
        id: int.parse(parts[0].trim()),
        idEstado: int.parse(parts[1].trim()),
        descripcion: parts[2].trim(),
        costo: int.parse(parts[3].trim()),
        valor: int.parse(parts[4].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Indirecto',
          indirecto.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
