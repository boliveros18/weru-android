import 'package:sqflite/sqflite.dart';
import '../models/servicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ServicioProvider {
  final Database db;
  ServicioProvider({required this.db});

  Future<void> insert(Servicio servicio) async {
    await db.insert(
      'Servicio',
      servicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Servicio> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'Servicio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de Servicio no encontrado!');
    }
    return Servicio.fromMap(items.first);
  }

  Future<List<Servicio>> getFiltered(int idTecnico) async {
    List<int> estados = [2, 10, 3, 4];
    String placeholders = estados.map((_) => '?').join(', ');

    final List<Map<String, Object?>> maps = await db.query(
      'Servicio',
      where: 'idEstadoServicio IN ($placeholders) AND idTecnico = ?',
      whereArgs: [...estados, idTecnico],
    );

    return maps.map((map) {
      return Servicio(
        id: map['id'] as int,
        idTecnico: map['idTecnico'] as int,
        idCliente: map['idCliente'] as int,
        idEstadoServicio: map['idEstadoServicio'] as int,
        nombre: map['nombre'] as String,
        descripcion: map['descripcion'] as String,
        direccion: map['direccion'] as String,
        idCiudad: map['idCiudad'] as int,
        latitud: (map['latitud'] as num).toDouble(),
        longitud: (map['longitud'] as num).toDouble(),
        fechaInicio: map['fechaInicio'] as String,
        fechayhorainicio: map['fechayhorainicio'] as String,
        fechaModificacion: map['fechaModificacion'] as String,
        fechaFin: map['fechaFin'] as String,
        idEquipo: map['idEquipo'] as int,
        idFalla: map['idFalla'] as int,
        observacionReporte: map['observacionReporte'] as String,
        radicado: map['radicado'] as String,
        idTipoServicio: map['idTipoServicio'] as int,
        cedulaFirma: map['cedulaFirma'] as String,
        nombreFirma: map['nombreFirma'] as String,
        archivoFirma: map['archivoFirma'] as String,
        orden: map['orden'] as int,
        fechaLlegada: map['fechaLlegada'] as String,
        comentarios: map['comentarios'] as String,
        consecutivo: map['consecutivo'] as int,
      );
    }).toList();
  }

  Future<void> update(Servicio servicio) async {
    await db.update(
      'Servicio',
      servicio.toMap(),
      where: 'id = ?',
      whereArgs: [servicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'Servicio',
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
      Servicio servicio = Servicio(
        id: int.parse(parts[0].trim()),
        idTecnico: int.parse(parts[1].trim()),
        idCliente: int.parse(parts[2].trim()),
        idEstadoServicio: int.parse(parts[3].trim()),
        nombre: parts[4].trim(),
        descripcion: parts[5].trim(),
        direccion: parts[6].trim(),
        idCiudad: int.parse(parts[7].trim()),
        latitud: double.parse(parts[8].trim()),
        longitud: double.parse(parts[9].trim()),
        fechaInicio: parts[10].trim(),
        fechayhorainicio: parts[11].trim(),
        fechaModificacion: parts[12].trim(),
        fechaFin: parts[13].trim(),
        idEquipo: int.parse(parts[14].trim()),
        idFalla: int.parse(parts[15].trim()),
        observacionReporte: parts[16].trim(),
        radicado: parts[17].trim(),
        idTipoServicio: int.parse(parts[18].trim()),
        cedulaFirma: parts[19].trim(),
        nombreFirma: parts[20].trim(),
        archivoFirma: parts[21].trim(),
        orden: int.parse(parts[22].trim()),
        fechaLlegada: parts[23].trim(),
        comentarios: parts[24].trim(),
        consecutivo: int.parse(parts[25].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'Servicio',
          servicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
