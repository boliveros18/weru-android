import 'package:archive/archive.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/providers/actividad_provider.dart';
import 'package:weru/database/providers/actividadmodelo_provider.dart';
import 'package:weru/database/providers/categoriaindicador_provider.dart';
import 'package:weru/database/providers/ciudad_provider.dart';
import 'package:weru/database/providers/cliente_provider.dart';
import 'package:weru/database/providers/diagnostico_provider.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/estadoservicio_provider.dart';
import 'package:weru/database/providers/falla_provider.dart';
import 'package:weru/database/providers/indicador_provider.dart';
import 'package:weru/database/providers/indicadormodelo_provider.dart';
import 'package:weru/database/providers/indirecto_provider.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/itemmodelo_provider.dart';
import 'package:weru/database/providers/modelo_provider.dart';
import 'package:weru/database/providers/novedad_provider.dart';
import 'package:weru/database/providers/registrocamposadicionales_provider.dart';
import 'package:weru/database/providers/tipocliente_provider.dart';
import 'package:weru/database/providers/tipoitem_provider.dart';
import 'package:weru/database/providers/tiposervicio_provider.dart';

Future<void> insertMasterFileInSqflite(
    ArchiveFile file, Database database) async {
  dynamic createProvider(String fileName) {
    switch (fileName) {
      case "Actividad.txt":
        return ActividadProvider(db: database);
      case "ActividadModelo.txt":
        return ActividadModeloProvider(db: database);
      case "CategoriaIndicador.txt":
        return CategoriaIndicadorProvider(db: database);
      case "Ciudad.txt":
        return CiudadProvider(db: database);
      case "Cliente.txt":
        return ClienteProvider(db: database);
      case "Diagnostico.txt":
        return DiagnosticoProvider(db: database);
      case "Equipo.txt":
        return EquipoProvider(db: database);
      case "EstadoServicio.txt":
        return EstadoServicioProvider(db: database);
      case "Falla.txt":
        return FallaProvider(db: database);
      case "Indicador.txt":
        return IndicadorProvider(db: database);
      case "IndicadorModelo.txt":
        return IndicadorModeloProvider(db: database);
      case "Indirecto.txt":
        return IndirectoProvider(db: database);
      case "Item.txt":
        return ItemProvider(db: database);
      case "ItemModelo.txt":
        return ItemModeloProvider(db: database);
      case "Modelo.txt":
        return ModeloProvider(db: database);
      case "Novedad.txt":
        return NovedadProvider(db: database);
      case "RegistroCamposAdicionales.txt":
        return RegistroCamposAdicionalesProvider(db: database);
      case "TipoCliente.txt":
        return TipoClienteProvider(db: database);
      case "TipoItem.txt":
        return TipoItemProvider(db: database);
      case "TipoServicio.txt":
        return TipoServicioProvider(db: database);
      default:
        return null;
    }
  }

  final provider = createProvider(file.name);
  if (provider != null) {
    await provider.insertInitFile(file);
  }
}
