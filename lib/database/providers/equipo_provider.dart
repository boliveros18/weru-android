import 'package:sqflite/sqflite.dart';
import '../models/equipo.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class EquipoProvider {
  final Database db;
  EquipoProvider({required this.db});

  Future<void> insert(Equipo equipo) async {
    await db.insert(
      'Equipo',
      equipo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Equipo> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Equipo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Equipo no encontrado!');
    }
    return Equipo.fromMap(items.first);
  }

  Future<List<Equipo>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Equipo');
    return maps.map((map) {
      return Equipo(
        id: map['id'] as int,
        serial: map['serial'] as String,
        nombre: map['nombre'] as String,
        fechaCompra: map['fechaCompra'] as String,
        fechaGarantia: map['fechaGarantia'] as String,
        idModelo: map['idModelo'] as int,
        idEstadoEquipo: map['idEstadoEquipo'] as int,
        idProveedor: map['idProveedor'] as int,
        idCliente: map['idCliente'] as int,
      );
    }).toList();
  }

  Future<void> update(Equipo equipo) async {
    await db.update(
      'Equipo',
      equipo.toMap(),
      where: 'id = ?',
      whereArgs: [equipo.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Equipo',
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
      Equipo equipo = Equipo(
        id: int.parse(parts[0].trim()),
        serial: parts[1].trim(),
        nombre: parts[2].trim(),
        fechaCompra: parts[3].trim(),
        fechaGarantia: parts[4].trim(),
        idModelo: int.parse(parts[5].trim()),
        idEstadoEquipo: int.parse(parts[6].trim()),
        idProveedor: int.parse(parts[7].trim()),
        idCliente: int.parse(parts[8].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Equipo',
          equipo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
