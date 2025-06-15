import 'dart:convert';
import 'package:weru/database/models/actividad.dart';
import 'package:weru/database/models/actividadmodelo.dart';
import 'package:weru/database/models/actividadservicio.dart';
import 'package:weru/database/models/adjuntoservicio.dart';
import 'package:weru/database/models/categoriaindicador.dart';
import 'package:weru/database/models/ciudad.dart';
import 'package:weru/database/models/cliente.dart';
import 'package:weru/database/models/diagnostico.dart';
import 'package:weru/database/models/diagnosticoservicio.dart';
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/estadoservicio.dart';
import 'package:weru/database/models/falla.dart';
import 'package:weru/database/models/fotoservicio.dart';
import 'package:weru/database/models/indicador.dart';
import 'package:weru/database/models/indicadormodelo.dart';
import 'package:weru/database/models/indicadorservicio.dart';
import 'package:weru/database/models/indirecto.dart';
import 'package:weru/database/models/indirectomodelo.dart';
import 'package:weru/database/models/indirectoservicio.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/itemactividadservicio.dart';
import 'package:weru/database/models/itemmodelo.dart';
import 'package:weru/database/models/itemservicio.dart';
import 'package:weru/database/models/maletin.dart';
import 'package:weru/database/models/modelo.dart';
import 'package:weru/database/models/novedad.dart';
import 'package:weru/database/models/novedadservicio.dart';
import 'package:weru/database/models/registrocamposadicionales.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/tecnico.dart';
import 'package:weru/database/models/tipocliente.dart';
import 'package:weru/database/models/tipoitem.dart';
import 'package:weru/database/models/tiposervicio.dart';
import 'package:weru/database/models/titulos.dart';
import 'package:weru/database/models/valoresindicador.dart';

import 'package:weru/functions/transform_json.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

Future<Map<String, List<Map<String, dynamic>>>> responseStageMessageXMLtoJSON(
    String xmlString) async {
  final document = XmlDocument.parse(xmlString);
  Future<String> TableList() async {
    return await rootBundle.loadString('assets/utils/tables.sql');
  }

  final tables = await TableList();
  final tableRegex = RegExp(r'(\w+)\s*\(([^)]+)\)');
  final matches = tableRegex.allMatches(tables);

  final Map<String, List<Map<String, dynamic>>> result = {};
  result.putIfAbsent("Error", () => []);

  for (var match in matches) {
    final table = match.group(1)!;
    result.putIfAbsent(table, () => []);
  }

  bool AddMessage(String model, dynamic map) {
    try {
      switch (model) {
        case 'Actividad':
          Actividad.fromMap(map);
          break;
        case 'ActividadModelo':
          ActividadModelo.fromMap(map);
          break;
        case 'ActividadServicio':
          ActividadServicio.fromMap(map);
          break;
        case 'AdjuntoServicio':
          AdjuntoServicio.fromMap(map);
          break;
        case 'CategoriaIndicador':
          CategoriaIndicador.fromMap(map);
          break;
        case 'Ciudad':
          Ciudad.fromMap(map);
          break;
        case 'Cliente':
          Cliente.fromMap(map);
          break;
        case 'Diagnostico':
          Diagnostico.fromMap(map);
          break;
        case 'DiagnosticoServicio':
          DiagnosticoServicio.fromMap(map);
          break;
        case 'Equipo':
          Equipo.fromMap(map);
          break;
        case 'EstadoServicio':
          EstadoServicio.fromMap(map);
          break;
        case 'Falla':
          Falla.fromMap(map);
          break;
        case 'FotoServicio':
          FotoServicio.fromMap(map);
          break;
        case 'Indicador':
          Indicador.fromMap(map);
          break;
        case 'IndicadorModelo':
          IndicadorModelo.fromMap(map);
          break;
        case 'IndicadorServicio':
          IndicadorServicio.fromMap(map);
          break;
        case 'Indirecto':
          Indirecto.fromMap(map);
          break;
        case 'IndirectoModelo':
          IndirectoModelo.fromMap(map);
          break;
        case 'IndirectoServicio':
          IndirectoServicio.fromMap(map);
          break;
        case 'Item':
          Item.fromMap(map);
          break;
        case 'ItemActividadServicio':
          ItemActividadServicio.fromMap(map);
          break;
        case 'ItemModelo':
          ItemModelo.fromMap(map);
          break;
        case 'ItemServicio':
          ItemServicio.fromMap(map);
          break;
        case 'Maletin':
          Maletin.fromMap(map);
          break;
        case 'Modelo':
          Modelo.fromMap(map);
          break;
        case 'Novedad':
          Novedad.fromMap(map);
          break;
        case 'NovedadServicio':
          NovedadServicio.fromMap(map);
          break;
        case 'RegistroCamposAdicionales':
          RegistroCamposAdicionales.fromMap(map);
          break;
        case 'Servicio':
          Servicio.fromMap(map);
          break;
        case 'Tecnico':
          Tecnico.fromMap(map);
          break;
        case 'TipoCliente':
          TipoCliente.fromMap(map);
          break;
        case 'TipoItem':
          TipoItem.fromMap(map);
          break;
        case 'TipoServicio':
          TipoServicio.fromMap(map);
          break;
        case 'Titulos':
          Titulos.fromMap(map);
          break;
        case 'ValoresIndicador':
          ValoresIndicador.fromMap(map);
          break;
      }

      for (var match in matches) {
        final table = match.group(1)!;
        if (model == table) {
          result[table]?.add(map);
          return true;
        }
      }
    } catch (e) {
      result["Error"]!.add({
        'table': model,
        'content': map,
        'description':
            'Alguna de sus propiedades no tiene ni value ni tipo valido.',
        'secundary': e
      });
      return false;
    }

    return false;
  }

  for (var stageMessage in document.findAllElements('StageMessage')) {
    try {
      final id = stageMessage.findElements('Id').single.innerText;
      final body = stageMessage.findElements('Mensaje').single.innerText;
      final model =
          stageMessage.findElements('FamiliaMensaje').single.innerText;
      final map = jsonDecode(body);

      if (model == "Servicio") {
        final service = transformJson(map);
        service.forEach((key, value) {
          value.forEach((map) {
            switch (key) {
              case "cliente":
                AddMessage("Cliente", map);
              case "equipo":
                AddMessage("Equipo", map);
              case "novedades":
                AddMessage("NovedadServicio", map);
              case "diagnosticos":
                AddMessage("DiagnosticoServicio", map);
              case "actividades":
                AddMessage("ActividadServicio", map);
              case "herramientas":
                AddMessage("ItemActividadServicio", map);
              case "repuestos":
                AddMessage("ItemServicio", map);
              case "indirectos":
                AddMessage("IndirectoServicio", map);
              case "fotos":
                AddMessage("FotoServicio", map);
              case "indicadores":
                AddMessage("IndicadorServicio", map);
              case "registroCamposAdicionales":
                AddMessage("RegistroCamposAdicionales", map);
            }
          });
        });
        FTPService.setMessageReceived(id);
      }

      final added = AddMessage(model, map);

      if (added) {
        FTPService.setMessageReceived(id);
      }
    } catch (e, stackTrace) {
      print("Error en xml to json: $e, $stackTrace");
    }
  }
  return result;
}
