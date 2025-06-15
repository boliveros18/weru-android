import 'package:sqflite/sqflite.dart';
import '../models/registrocamposadicionales.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class RegistroCamposAdicionalesProvider {
  final Database db;
  RegistroCamposAdicionalesProvider({required this.db});

  Future<void> insert(
      RegistroCamposAdicionales registrocamposadicionales) async {
    await db.insert(
      'RegistroCamposAdicionales',
      registrocamposadicionales.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<RegistroCamposAdicionales> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'RegistroCamposAdicionales',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de RegistroCamposAdicionales no encontrado!');
    }
    return RegistroCamposAdicionales.fromMap(items.first);
  }

  Future<List<RegistroCamposAdicionales>> getAll() async {
    final List<Map<String, Object?>> maps =
        await db.query('RegistroCamposAdicionales');
    return maps.map((map) {
      return RegistroCamposAdicionales(
        id: map['id'] as int,
        idCamposAdicionales: map['idCamposAdicionales'] as int,
        idRegistro: map['idRegistro'] as int,
        valor: map['valor'] as int,
        nombre: map['nombre'] as String,
      );
    }).toList();
  }

  Future<void> update(
      RegistroCamposAdicionales registrocamposadicionales) async {
    await db.update(
      'RegistroCamposAdicionales',
      registrocamposadicionales.toMap(),
      where: 'id = ?',
      whereArgs: [registrocamposadicionales.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'RegistroCamposAdicionales',
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
      RegistroCamposAdicionales registrocamposadicionales =
          RegistroCamposAdicionales(
        id: int.parse(parts[0].trim()),
        idCamposAdicionales: int.parse(parts[1].trim()),
        idRegistro: int.parse(parts[2].trim()),
        nombre: parts[3].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'RegistroCamposAdicionales',
          registrocamposadicionales.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
