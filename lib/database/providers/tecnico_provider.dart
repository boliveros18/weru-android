import 'package:sqflite/sqflite.dart';
import '../models/tecnico.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class TecnicoProvider {
  final Database db;
  TecnicoProvider({required this.db});

  Future<void> insert(Tecnico tecnico) async {
    await db.insert(
      'Tecnico',
      tecnico.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Tecnico> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Tecnico',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Tecnico no encontrado!');
    }
    return Tecnico.fromMap(items.first);
  }

  Future<int> getItemIdByUser(String user) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Tecnico',
      where: 'usuario = ?',
      whereArgs: [user],
    );
    if (items.isEmpty) {
      throw Exception('Item de Tecnico no encontrado!');
    }
    return Tecnico.fromMap(items.first).id;
  }

  Future<List<Tecnico>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Tecnico');
    return maps.map((map) {
      return Tecnico(
        id: map['id'] as int,
        cedula: map['cedula'] as String,
        nombre: map['nombre'] as String,
        idProveedor: map['idProveedor'] as int,
        idEstadoTecnico: map['idEstadoTecnico'] as int,
        usuario: map['usuario'] as String,
        clave: map['clave'] as String,
        telefono: map['telefono'] as String,
        celular: map['celular'] as String,
        latitud: (map['latitud'] as num).toDouble(),
        longitud: (map['longitud'] as num).toDouble(),
        androidID: map['androidID'] as String,
        fechaPulso: map['fechaPulso'] as String,
        versionApp: map['versionApp'] as String,
        situacionActual: map['situacionActual'] as String,
      );
    }).toList();
  }

  Future<void> update(Tecnico tecnico) async {
    await db.update(
      'Tecnico',
      tecnico.toMap(),
      where: 'id = ?',
      whereArgs: [tecnico.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Tecnico',
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
      Tecnico tecnico = Tecnico(
        id: int.parse(parts[0].trim()),
        cedula: parts[1].trim(),
        nombre: parts[2].trim(),
        idProveedor: int.parse(parts[3].trim()),
        idEstadoTecnico: int.parse(parts[4].trim()),
        usuario: parts[5].trim(),
        clave: parts[6].trim(),
        telefono: parts[7].trim(),
        celular: parts[8].trim(),
        latitud: double.parse(parts[9].trim()),
        longitud: double.parse(parts[10].trim()),
        androidID: parts[11].trim(),
        fechaPulso: parts[12].trim(),
        versionApp: parts[13].trim(),
        situacionActual: parts[14].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Tecnico',
          tecnico.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
