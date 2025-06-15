import 'package:sqflite/sqflite.dart';
import '../models/maletin.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class MaletinProvider {
  final Database db;
  MaletinProvider({required this.db});

  Future<void> insert(Maletin maletin) async {
    await db.insert(
      'Maletin',
      maletin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Maletin> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Maletin',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Maletin no encontrado!');
    }
    return Maletin.fromMap(items.first);
  }

  Future<List<Maletin>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Maletin');
    return maps.map((map) {
      return Maletin(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idTecnico: map['idTecnico'] as int,
        cantidad: map['cantidad'] as int,
        costo: map['costo'] as double,
        valor: map['valor'] as double,
      );
    }).toList();
  }

  Future<List<Maletin>> getAllByIdTecnico(int idTecnico) async {
    final List<Map<String, Object?>> maps = await db.query(
      'Maletin',
      where: 'idTecnico = ?',
      whereArgs: [idTecnico],
    );
    return maps.map((map) {
      return Maletin(
        id: map['id'] as int,
        idItem: map['idItem'] as int,
        idTecnico: map['idTecnico'] as int,
        cantidad: map['cantidad'] as int,
        costo: map['costo'] as double,
        valor: map['valor'] as double,
      );
    }).toList();
  }

  Future<void> update(Maletin maletin) async {
    await db.update(
      'Maletin',
      maletin.toMap(),
      where: 'id = ?',
      whereArgs: [maletin.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Maletin',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByIdItem(int id) async {
    await db.delete(
      'Maletin',
      where: 'idItem = ?',
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
      Maletin maletin = Maletin(
        id: int.parse(parts[0].trim()),
        idItem: int.parse(parts[1].trim()),
        idTecnico: int.parse(parts[2].trim()),
        cantidad: int.parse(parts[3].trim()),
        costo: double.parse(parts[4].trim()),
        valor: double.parse(parts[5].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Maletin',
          maletin.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
