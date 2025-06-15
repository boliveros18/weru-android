import 'package:sqflite/sqflite.dart';
import '../models/cliente.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ClienteProvider {
  final Database db;
  ClienteProvider({required this.db});

  Future<void> insert(Cliente cliente) async {
    await db.insert(
      'Cliente',
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Cliente> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Cliente',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Cliente no encontrado!');
    }
    return Cliente.fromMap(items.first);
  }

  Future<List<Cliente>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('Cliente');
    return maps.map((map) {
      return Cliente(
        id: map['id'] as int,
        nombre: map['nombre'] as String,
        direccion: map['direccion'] as String,
        idCiudad: map['idCiudad'] as int,
        telefono: map['telefono'] as String,
        celular: map['celular'] as String,
        idTipoCliente: map['idTipoCliente'] as int,
        idTipoDocumento: map['idTipoDocumento'] as int,
        numDocumento: map['numDocumento'] as String,
        establecimiento: map['establecimiento'] as String,
        contacto: map['contacto'] as String,
        idEstado: map['idEstado'] as int,
        correo: map['correo'] as String,
      );
    }).toList();
  }

  Future<void> update(Cliente cliente) async {
    await db.update(
      'Cliente',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Cliente',
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
      Cliente cliente = Cliente(
        id: int.parse(parts[0].trim()),
        nombre: parts[1].trim(),
        direccion: parts[2].trim(),
        idCiudad: int.parse(parts[3].trim()),
        telefono: parts[4].trim(),
        celular: parts[5].trim(),
        idTipoCliente: int.parse(parts[6].trim()),
        idTipoDocumento: int.parse(parts[7].trim()),
        numDocumento: parts[8].trim(),
        establecimiento: parts[9].trim(),
        contacto: parts[10].trim(),
        idEstado: int.parse(parts[11].trim()),
        correo: parts[12].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'Cliente',
          cliente.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
