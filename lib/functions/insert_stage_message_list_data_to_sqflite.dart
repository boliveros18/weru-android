import 'package:sqflite/sqflite.dart';
import 'package:weru/database/providers/actividad_provider.dart';
import 'package:weru/database/providers/actividadmodelo_provider.dart';
import 'package:weru/database/providers/actividadservicio_provider.dart';
import 'package:weru/database/providers/adjuntoservicio_provider.dart';
import 'package:weru/database/providers/categoriaindicador_provider.dart';
import 'package:weru/database/providers/ciudad_provider.dart';
import 'package:weru/database/providers/cliente_provider.dart';
import 'package:weru/database/providers/diagnostico_provider.dart';
import 'package:weru/database/providers/diagnosticoservicio_provider.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/estadoservicio_provider.dart';
import 'package:weru/database/providers/falla_provider.dart';
import 'package:weru/database/providers/fotoservicio_provider.dart';
import 'package:weru/database/providers/indicador_provider.dart';
import 'package:weru/database/providers/indicadormodelo_provider.dart';
import 'package:weru/database/providers/indicadorservicio_provider.dart';
import 'package:weru/database/providers/indirecto_provider.dart';
import 'package:weru/database/providers/indirectomodelo_provider.dart';
import 'package:weru/database/providers/indirectoservicio_provider.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/itemactividadservicio_provider.dart';
import 'package:weru/database/providers/itemmodelo_provider.dart';
import 'package:weru/database/providers/itemservicio_provider.dart';
import 'package:weru/database/providers/maletin_provider.dart';
import 'package:weru/database/providers/modelo_provider.dart';
import 'package:weru/database/providers/novedad_provider.dart';
import 'package:weru/database/providers/novedadservicio_provider.dart';
import 'package:weru/database/providers/registrocamposadicionales_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/providers/tipocliente_provider.dart';
import 'package:weru/database/providers/tipoitem_provider.dart';
import 'package:weru/database/providers/tiposervicio_provider.dart';
import 'package:weru/database/providers/titulos_provider.dart';
import 'package:weru/database/providers/valoresindicador_provider.dart';

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

Future<bool> insertStageMessageListDataToSqflite(
    dynamic data, Database database) async {
  try {
    final tableProviders = {
      'Actividad': (map) =>
          ActividadProvider(db: database).insert(Actividad.fromMap(map)),
      'ActividadModelo': (map) => ActividadModeloProvider(db: database)
          .insert(ActividadModelo.fromMap(map)),
      'ActividadServicio': (map) => ActividadServicioProvider(db: database)
          .insert(ActividadServicio.fromMap(map)),
      'AdjuntoServicio': (map) => AdjuntoServicioProvider(db: database)
          .insert(AdjuntoServicio.fromMap(map)),
      'CategoriaIndicador': (map) => CategoriaIndicadorProvider(db: database)
          .insert(CategoriaIndicador.fromMap(map)),
      'Ciudad': (map) =>
          CiudadProvider(db: database).insert(Ciudad.fromMap(map)),
      'Cliente': (map) =>
          ClienteProvider(db: database).insert(Cliente.fromMap(map)),
      'Diagnostico': (map) =>
          DiagnosticoProvider(db: database).insert(Diagnostico.fromMap(map)),
      'DiagnosticoServicio': (map) => DiagnosticoServicioProvider(db: database)
          .insert(DiagnosticoServicio.fromMap(map)),
      'Equipo': (map) =>
          EquipoProvider(db: database).insert(Equipo.fromMap(map)),
      'EstadoServicio': (map) => EstadoServicioProvider(db: database)
          .insert(EstadoServicio.fromMap(map)),
      'Falla': (map) => FallaProvider(db: database).insert(Falla.fromMap(map)),
      'FotoServicio': (map) =>
          FotoServicioProvider(db: database).insert(FotoServicio.fromMap(map)),
      'Indicador': (map) =>
          IndicadorProvider(db: database).insert(Indicador.fromMap(map)),
      'IndicadorModelo': (map) => IndicadorModeloProvider(db: database)
          .insert(IndicadorModelo.fromMap(map)),
      'IndicadorServicio': (map) => IndicadorServicioProvider(db: database)
          .insert(IndicadorServicio.fromMap(map)),
      'Indirecto': (map) =>
          IndirectoProvider(db: database).insert(Indirecto.fromMap(map)),
      'IndirectoModelo': (map) => IndirectoModeloProvider(db: database)
          .insert(IndirectoModelo.fromMap(map)),
      'IndirectoServicio': (map) => IndirectoServicioProvider(db: database)
          .insert(IndirectoServicio.fromMap(map)),
      'Item': (map) => ItemProvider(db: database).insert(Item.fromMap(map)),
      'ItemActividadServicio': (map) =>
          ItemActividadServicioProvider(db: database)
              .insert(ItemActividadServicio.fromMap(map)),
      'ItemModelo': (map) =>
          ItemModeloProvider(db: database).insert(ItemModelo.fromMap(map)),
      'ItemServicio': (map) =>
          ItemServicioProvider(db: database).insert(ItemServicio.fromMap(map)),
      'Maletin': (map) =>
          MaletinProvider(db: database).insert(Maletin.fromMap(map)),
      'Modelo': (map) =>
          ModeloProvider(db: database).insert(Modelo.fromMap(map)),
      'Novedad': (map) =>
          NovedadProvider(db: database).insert(Novedad.fromMap(map)),
      'NovedadServicio': (map) => NovedadServicioProvider(db: database)
          .insert(NovedadServicio.fromMap(map)),
      'RegistroCamposAdicionales': (map) =>
          RegistroCamposAdicionalesProvider(db: database)
              .insert(RegistroCamposAdicionales.fromMap(map)),
      'Servicio': (map) =>
          ServicioProvider(db: database).insert(Servicio.fromMap(map)),
      'Tecnico': (map) =>
          TecnicoProvider(db: database).insert(Tecnico.fromMap(map)),
      'TipoCliente': (map) =>
          TipoClienteProvider(db: database).insert(TipoCliente.fromMap(map)),
      'TipoItem': (map) =>
          TipoItemProvider(db: database).insert(TipoItem.fromMap(map)),
      'TipoServicio': (map) =>
          TipoServicioProvider(db: database).insert(TipoServicio.fromMap(map)),
      'Titulos': (map) =>
          TitulosProvider(db: database).insert(Titulos.fromMap(map)),
      'ValoresIndicador': (map) => ValoresIndicadorProvider(db: database)
          .insert(ValoresIndicador.fromMap(map)),
    };

    for (var table in tableProviders.keys) {
      if (data[table] != null) {
        for (var map in data[table]) {
          await tableProviders[table]!(map);
        }
      }
    }
    return true;
  } catch (e, stackTrace) {
    print("Error inserting stage messages to sqflite: $e, $stackTrace");
    return false;
  }
}
