import 'package:sqflite/sqflite.dart';
import '../models/indirectomodelo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndirectoModeloProvider {
  final Database db;
  IndirectoModeloProvider({required this.db});

  Future<void> insert(IndirectoModelo indirectomodelo) async {
    await db.insert(
      'IndirectoModelo',
      indirectomodelo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<IndirectoModelo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'IndirectoModelo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de IndirectoModelo no encontrado!');
    }
    return IndirectoModelo.fromMap(items.first);
  }

  Future<List<IndirectoModelo>> getAllByIdModelo(int idModelo) async {
    final List<Map<String, Object?>> maps = await db.query(
      'IndirectoModelo',
      where: 'idModelo = ?',
      whereArgs: [idModelo],
    );
    return maps.map((map) {
      return IndirectoModelo(
        id: map['id'] as int,
        idIndirecto: map['idIndirecto'] as int,
        idModelo: map['idModelo'] as int,
      );
    }).toList();
  }

  Future<void> update(IndirectoModelo indirectomodelo) async {
    await db.update(
      'IndirectoModelo',
      indirectomodelo.toMap(),
      where: 'id = ?',
      whereArgs: [indirectomodelo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'IndirectoModelo',
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
      IndirectoModelo indirectomodelo = IndirectoModelo(
        id: int.parse(parts[0].trim()),
        idIndirecto: int.parse(parts[1].trim()),
        idModelo: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'IndirectoModelo',
          indirectomodelo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
