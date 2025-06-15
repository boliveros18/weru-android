import 'package:sqflite/sqflite.dart';
import '../models/adjuntoservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class AdjuntoServicioProvider {
  final Database db;
  AdjuntoServicioProvider({required this.db});

  Future<void> insert(AdjuntoServicio adjuntoservicio) async {
    await db.insert(
      'AdjuntoServicio',
      adjuntoservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AdjuntoServicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'AdjuntoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de AdjuntoServicio no encontrado!');
    }
    return AdjuntoServicio.fromMap(items.first);
  }

  Future<List<AdjuntoServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('AdjuntoServicio');
    return maps.map((map) {
      return AdjuntoServicio(
        id: map['id'] as int,
        idServicio: map['idServicio'] as int,
        idTecnico: map['idTecnico'] as int,
        titulo: map['titulo'] as String,
        descripcion: map['descripcion'] as String,
        tipo: map['tipo'] as String,
      );
    }).toList();
  }

  Future<void> update(AdjuntoServicio adjuntoservicio) async {
    await db.update(
      'AdjuntoServicio',
      adjuntoservicio.toMap(),
      where: 'id = ?',
      whereArgs: [adjuntoservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'AdjuntoServicio',
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
      AdjuntoServicio adjuntoservicio = AdjuntoServicio(
        id: int.parse(parts[0].trim()),
        idServicio: int.parse(parts[1].trim()),
        idTecnico: int.parse(parts[2].trim()),
        titulo: parts[3].trim(),
        descripcion: parts[4].trim(),
        tipo: parts[5].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'AdjuntoServicio',
          adjuntoservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
