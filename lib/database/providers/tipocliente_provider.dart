import 'package:sqflite/sqflite.dart';
import '../models/tipocliente.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class TipoClienteProvider {
  final Database db;
  TipoClienteProvider({required this.db});

  Future<void> insert(TipoCliente tipocliente) async {
    await db.insert(
      'TipoCliente',
      tipocliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TipoCliente> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'TipoCliente',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de TipoCliente no encontrado!');
    }
    return TipoCliente.fromMap(items.first);
  }

  Future<List<TipoCliente>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('TipoCliente');
    return maps.map((map) {
      return TipoCliente(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(TipoCliente tipocliente) async {
    await db.update(
      'TipoCliente',
      tipocliente.toMap(),
      where: 'id = ?',
      whereArgs: [tipocliente.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'TipoCliente',
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
      TipoCliente tipocliente = TipoCliente(
        id: int.parse(parts[0].trim()),
        nombre: parts[1].trim(),
        descripcion: parts[2].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'TipoCliente',
          tipocliente.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
