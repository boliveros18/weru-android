import 'package:weru/database/models/actividad.dart';
import 'package:weru/database/models/actividadservicio.dart';
import 'package:weru/database/models/ciudad.dart';
import 'package:weru/database/models/cliente.dart';
import 'package:weru/database/models/diagnostico.dart';
import 'package:weru/database/models/diagnosticoservicio.dart';
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/estadoservicio.dart';
import 'package:weru/database/models/falla.dart';
import 'package:weru/database/models/fotoservicio.dart';
import 'package:weru/database/models/indicador.dart';
import 'package:weru/database/models/indicadorservicio.dart';
import 'package:weru/database/models/indirecto.dart';
import 'package:weru/database/models/indirectoservicio.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/itemactividadservicio.dart';
import 'package:weru/database/models/itemservicio.dart';
import 'package:weru/database/models/maletin.dart';
import 'package:weru/database/models/modelo.dart';
import 'package:weru/database/models/novedad.dart';
import 'package:weru/database/models/novedadservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/tiposervicio.dart';
import 'package:weru/database/providers/actividad_provider.dart';
import 'package:weru/database/providers/actividadservicio_provider.dart';
import 'package:weru/database/providers/ciudad_provider.dart';
import 'package:weru/database/providers/cliente_provider.dart';
import 'package:weru/database/providers/diagnostico_provider.dart';
import 'package:weru/database/providers/diagnosticoservicio_provider.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/estadoservicio_provider.dart';
import 'package:weru/database/providers/falla_provider.dart';
import 'package:weru/database/providers/fotoservicio_provider.dart';
import 'package:weru/database/providers/indicador_provider.dart';
import 'package:weru/database/providers/indicadorservicio_provider.dart';
import 'package:weru/database/providers/indirecto_provider.dart';
import 'package:weru/database/providers/indirectoservicio_provider.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/itemactividadservicio_provider.dart';
import 'package:weru/database/providers/itemservicio_provider.dart';
import 'package:weru/database/providers/maletin_provider.dart';
import 'package:weru/database/providers/modelo_provider.dart';
import 'package:weru/database/providers/novedad_provider.dart';
import 'package:weru/database/providers/novedadservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/providers/tiposervicio_provider.dart';

class DatabaseMain {
  final String path;
  String user = "";
  List<Servicio> services = [];
  List<Cliente?> clients = [];
  List<Equipo?> equipments = [];
  List<Ciudad?> cities = [];
  List<Modelo?> models = [];
  List<EstadoServicio?> servicesStatus = [];
  List<TipoServicio?> servicesTypes = [];
  List<Falla?> fails = [];
  List<Novedad> news = [];
  List<NovedadServicio> newsServices = [];
  List<Diagnostico> diagnoses = [];
  List<DiagnosticoServicio> diagnosesServices = [];
  List<Actividad> activities = [];
  List<ActividadServicio> activitiesServices = [];
  List<Item> refills = [];
  List<ItemServicio> refillsServices = [];
  List<Maletin> briefcase = [];
  List<Indirecto> overheads = [];
  List<IndirectoServicio> overheadsServices = [];
  List<Indicador> indicators = [];
  List<IndicadorServicio> indicatorsServices = [];
  List<FotoServicio> photosServices = [];

  List<Item> tools = [];

  DatabaseMain({required this.path}) {}

  Future<void> setUser(String username) async {
    user = username;
  }

  Future<void> getServices() async {
    final database = await db;
    try {
      int idTecnico = await TecnicoProvider(db: database).getItemIdByUser(user);
      final _services =
          await ServicioProvider(db: database).getFiltered(idTecnico);

      equipments = (await Future.wait(
        _services.map((service) async {
          try {
            return await EquipoProvider(db: database)
                .getItemById(service.idEquipo);
          } catch (_) {
            return null;
          }
        }),
      ));

      clients = (await Future.wait(
        _services.map((service) async {
          try {
            return await ClienteProvider(db: database)
                .getItemById(service.idCliente);
          } catch (_) {
            return null;
          }
        }),
      ));

      cities = (await Future.wait(
        _services.map((service) async {
          try {
            return await CiudadProvider(db: database)
                .getItemById(service.idCiudad);
          } catch (_) {
            return null;
          }
        }),
      ));

      models = (await Future.wait(
        equipments.map((equipo) async {
          try {
            return await ModeloProvider(db: database)
                .getItemById(equipo!.idModelo);
          } catch (_) {
            return null;
          }
        }),
      ));

      servicesStatus = (await Future.wait(
        _services.map((service) async {
          try {
            return await EstadoServicioProvider(db: database)
                .getItemById(service.idEstadoServicio);
          } catch (_) {
            return null;
          }
        }),
      ));

      servicesTypes = (await Future.wait(
        _services.map((service) async {
          try {
            return await TipoServicioProvider(db: database)
                .getItemById(service.idTipoServicio);
          } catch (_) {
            return null;
          }
        }),
      ));

      fails = (await Future.wait(
        _services.map((service) async {
          try {
            return await FallaProvider(db: database)
                .getItemById(service.idFalla);
          } catch (_) {
            return null;
          }
        }),
      ));

      services = _services;
    } catch (e, stackTrace) {
      print("Error getServices() in main database: $e, $stackTrace");
    }
  }

  Future<void> getNews(int idService) async {
    final database = await db;
    try {
      final _newsServices = await NovedadServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedNews = await Future.wait(
        _newsServices.map((_new) async {
          try {
            return await NovedadProvider(db: database)
                .getItemById(_new.idNovedad);
          } catch (_) {
            return null;
          }
        }),
      );

      news = fetchedNews.whereType<Novedad>().toList();
      newsServices = _newsServices;
    } catch (e, stackTrace) {
      print("Error getNews() in main database: $e, $stackTrace");
    }
  }

  Future<void> getDiagnoses(int idService) async {
    final database = await db;
    try {
      final _diagnosesServices = await DiagnosticoServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedDiagnoses = await Future.wait(
        _diagnosesServices.map((diagnosis) async {
          try {
            return await DiagnosticoProvider(db: database)
                .getItemById(diagnosis.idDiagnostico);
          } catch (_) {
            return null;
          }
        }),
      );

      diagnoses = fetchedDiagnoses.whereType<Diagnostico>().toList();
      diagnosesServices = _diagnosesServices;
    } catch (e, stackTrace) {
      print("Error getDiagnoses() in main database: $e, $stackTrace");
    }
  }

  Future<void> getActivities(int idService) async {
    final database = await db;
    try {
      final _activitiesServices = await ActividadServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedActivities = await Future.wait(
        _activitiesServices.map((activity) async {
          try {
            return await ActividadProvider(db: database)
                .getItemById(activity.idActividad);
          } catch (_) {
            return null;
          }
        }),
      );

      activities = fetchedActivities.whereType<Actividad>().toList();
      activitiesServices = _activitiesServices;
    } catch (e, stackTrace) {
      print("Error getActivities() in main database: $e, $stackTrace");
    }
  }

  Future<void> getRefills(int idService) async {
    final database = await db;
    try {
      final _refillsServices = await ItemServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedRefills = await Future.wait(
        _refillsServices.map((item) async {
          try {
            return await ItemProvider(db: database).getItemById(item.idItem);
          } catch (_) {
            return null;
          }
        }),
      );

      refills = fetchedRefills.whereType<Item>().toList();
      refillsServices = _refillsServices;
    } catch (e, stackTrace) {
      print("Error getRefills() in main database: $e, $stackTrace");
    }
  }

  Future<void> getItems(int idTecnico) async {
    final database = await db;
    try {
      final _briefcase =
          await MaletinProvider(db: database).getAllByIdTecnico(idTecnico);

      briefcase = _briefcase;
    } catch (e, stackTrace) {
      print("Error getTools() in main database: $e, $stackTrace");
    }
  }

  Future<void> getTools(int idService) async {
    final database = await db;
    try {
      final _activitiesServices = await ActividadServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedItems = await Future.wait(
        _activitiesServices.map((activity) async {
          return await ItemActividadServicioProvider(db: database)
              .getItemsByIdActividadServicio(activity.id!);
        }),
      );

      List<ItemActividadServicio> itemActivityService = fetchedItems
          .where((list) => list.isNotEmpty)
          .expand((list) => list)
          .toList();

      tools = await Future.wait(
        itemActivityService.map((item) async {
          return await ItemProvider(db: database).getItemById(item.idItem);
        }),
      );
    } catch (e, stackTrace) {
      print("Error getActivities() in main database: $e, $stackTrace");
    }
  }

  Future<void> getOverheads(int idService) async {
    final database = await db;
    try {
      final _overheadsServices = await IndirectoServicioProvider(db: database)
          .getAllByIdServicio(idService);

      final fetchedOverheads = await Future.wait(
        _overheadsServices.map((item) async {
          try {
            return await IndirectoProvider(db: database)
                .getItemById(item.idIndirecto);
          } catch (_) {
            return null;
          }
        }),
      );

      overheads = fetchedOverheads.whereType<Indirecto>().toList();
      overheadsServices = _overheadsServices;
    } catch (e, stackTrace) {
      print("Error getOverheads() in main database: $e, $stackTrace");
    }
  }

  Future<void> getIndicators(int idService, int idTecnico) async {
    final database = await db;
    try {
      final _indicatorsServices = await IndicadorServicioProvider(db: database)
          .getAllByIdServicio(idService, idTecnico);

      final fetchedIndicators = await Future.wait(
        _indicatorsServices.map((item) async {
          try {
            return await IndicadorProvider(db: database)
                .getItemById(item.idIndicador);
          } catch (_) {
            return null;
          }
        }),
      );

      indicators = fetchedIndicators.whereType<Indicador>().toList();
      indicatorsServices = _indicatorsServices;
    } catch (e, stackTrace) {
      print("Error getIndicators() in main database: $e, $stackTrace");
    }
  }

  Future<void> getPhotosService(int idService) async {
    final database = await db;
    try {
      final _photosServices = await FotoServicioProvider(db: database)
          .getAllByIdServicio(idService);
      photosServices = _photosServices;
    } catch (e, stackTrace) {
      print("Error getPhotosService() in main database: $e, $stackTrace");
    }
  }

  Future<Database> onCreate() async {
    return await db;
  }

  Future<Database> get db async {
    return openDatabase(
      join(path, 'weru.db'),
      onCreate: (db, version) async {
        await onCreateTables(db);
      },
      version: 1,
    );
  }

  Future<void> onCreateTables(Database db) async {
    await db.execute(
      'CREATE TABLE Actividad (id INTEGER PRIMARY KEY, codigoExt TEXT, descripcion TEXT, costo INTEGER, valor INTEGER, idEstadoActividad INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ActividadModelo (id INTEGER PRIMARY KEY, idActividad INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ActividadServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idActividad INTEGER NOT NULL, idServicio INTEGER NOT NULL, cantidad INTEGER, costo INTEGER, valor INTEGER, ejecutada INTEGER DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE AdjuntoServicio (id INTEGER PRIMARY KEY, idServicio INTEGER NOT NULL, idTecnico INTEGER, titulo TEXT, descripcion TEXT, tipo TEXT)',
    );
    await db.execute(
      'CREATE TABLE CategoriaIndicador (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Ciudad (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL, estado INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE Cliente (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, idCiudad INTEGER, telefono TEXT, celular TEXT, idTipoCliente INTEGER, idTipoDocumento INTEGER, numDocumento TEXT, establecimiento TEXT, contacto TEXT, idEstado INTEGER, correo TEXT)',
    );
    await db.execute(
      'CREATE TABLE Diagnostico (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE DiagnosticoServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idServicio INTEGER, idDiagnostico INTEGER)',
    );
    await db.execute(
        'CREATE TABLE Equipo (id INTEGER PRIMARY KEY, serial TEXT, nombre TEXT, fechaCompra TEXT, fechaGarantia TEXT, idModelo INTEGER, idEstadoEquipo INTEGER, idProveedor INTEGER, idCliente INTEGER)');
    await db.execute(
      'CREATE TABLE EstadoServicio (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Falla (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE FotoServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idServicio INTEGER NOT NULL, archivo BLOB, comentario TEXT)',
    );
    await db.execute(
      'CREATE TABLE Indicador (id INTEGER PRIMARY KEY, idEstadoIndicador INTEGER NOT NULL, descripcion TEXT, valorMin decimal(18, 3), valorMax decimal(18, 3), tipo TEXT, icono TEXT)',
    );
    await db.execute(
      'CREATE TABLE IndicadorModelo (id INTEGER PRIMARY KEY, idIndicador INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndicadorServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idIndicador INTEGER NOT NULL, idServicio INTEGER NOT NULL, idTecnico INTEGER,valor TEXT)',
    );
    await db.execute(
      'CREATE TABLE Indirecto (id INTEGER PRIMARY KEY, idEstado INTEGER NOT NULL, descripcion TEXT NOT NULL, costo INTEGER, valor INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndirectoModelo (id INTEGER PRIMARY KEY, idIndirecto INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndirectoServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idIndirecto INTEGER NOT NULL, idServicio INTEGER NOT NULL, cantidad INTEGER, costo INTEGER, valor INTEGER)',
    );
    await db.execute(
      'CREATE TABLE Item (id INTEGER PRIMARY KEY, SKU TEXT NOT NULL, descripcion TEXT, tipo INTEGER, costo INTEGER, precio INTEGER, idEstadoItem INTEGER, foto TEXT)',
    );
    await db.execute(
      'CREATE TABLE ItemActividadServicio (id INTEGER PRIMARY KEY, idItem INTEGER NOT NULL, idTipo INTEGER NOT NULL, idActividadServicio INTEGER NOT NULL, cantidadReq REAL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE ItemModelo (id INTEGER PRIMARY KEY, idItem INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ItemServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idItem INTEGER NOT NULL, idServicio INTEGER NOT NULL, cantidad REAL DEFAULT 0, costo INTEGER, valor INTEGER, cantidadReq REAL DEFAULT 0, fechaUltimaVez TEXT, vidaUtil TEXT)',
    );
    await db.execute(
      'CREATE TABLE Maletin (id INTEGER PRIMARY KEY AUTOINCREMENT, idItem INTEGER NOT NULL, idTecnico INTEGER NOT NULL, cantidad INTEGER, costo REAL, valor REAL)',
    );
    await db.execute(
      'CREATE TABLE Modelo (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Novedad (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE NovedadServicio (id INTEGER PRIMARY KEY AUTOINCREMENT, idServicio INTEGER, idNovedad INTEGER)',
    );
    await db.execute(
      'CREATE TABLE RegistroCamposAdicionales (id INTEGER PRIMARY KEY, idCamposAdicionales INTEGER NOT NULL, idRegistro INTEGER NOT NULL, valor INTEGER, nombre INTEGER)',
    );
    await db.execute(
      'CREATE TABLE Servicio (id INTEGER PRIMARY KEY, idTecnico INTEGER NOT NULL, idCliente INTEGER NOT NULL, idEstadoServicio INTEGER NOT NULL, nombre TEXT NULL, descripcion TEXT NULL, direccion TEXT NULL, idCiudad INTEGER NOT NULL, latitud decimal(11, 8) NOT NULL, longitud decimal(11, 8) NOT NULL, fechaInicio TEXT NULL, fechayhorainicio TEXT NULL, fechaModificacion TEXT NULL, fechaFin TEXT NULL, idEquipo INTEGER NULL, idFalla INTEGER NOT NULL, observacionReporte TEXT NULL, radicado TEXT NULL, idTipoServicio INTEGER NULL, cedulaFirma TEXT NULL, nombreFirma TEXT NULL, archivoFirma TEXT NULL, orden INTEGER DEFAULT 0, fechaLlegada TEXT NULL, comentarios TEXT NULL, consecutivo int NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE StageMessage (id INTEGER PRIMARY KEY AUTOINCREMENT, Message TEXT NOT NULL, MessageFamily TEXT NOT NULL, Action TEXT NOT NULL, Sent INTEGER NOT NULL, CreatedAt TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE Tecnico (id INTEGER PRIMARY KEY, cedula TEXT NOT NULL, nombre TEXT NULL, idProveedor INTEGER NULL, idEstadoTecnico INTEGER NULL, usuario TEXT NOT NULL, clave TEXT NULL, telefono TEXT NULL, celular TEXT NULL, latitud REAL NULL, longitud REAL NULL, androidID TEXT NULL, fechaPulso TEXT NULL, versionApp TEXT NULL, situacionActual TEXT NULL)',
    );
    await db.execute(
      'CREATE TABLE TipoCliente (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE TipoItem (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE TipoServicio (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Titulos (id INTEGER PRIMARY KEY, idCampo INTEGER, campo TEXT, valor TEXT)',
    );
    await db.execute(
      'CREATE TABLE ValoresIndicador (id INTEGER PRIMARY KEY, idIndicador INTEGER, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Pulso ( id INTEGER PRIMARY KEY AUTOINCREMENT, idTecnico INTEGER NOT NULL, latitud REAL NULL, longitud REAL NULL, fechaPulso TEXT NULL, situacionActual TEXT NULL)',
    );
  }
}
