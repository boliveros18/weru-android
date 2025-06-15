import 'dart:io';
import 'package:path_provider/path_provider.dart';

const String appHeadquarterMaxDistanceMeters = '150';
const String appHeadquarterLongitude = '-73.265033';
const String appHeadquarterLatitude = '9.884686';
const String appGpsTrackingTime = '10000';
const String appGpsTrackingMinDistance = '10';
const String appMasterFilesFolder = 'MasterData';
const String appImageFilesFolder = 'Images';
const String appImageBakFilesFolder = 'Images_bak';
const String appMaintenancePassword = '509569';
const String appRibHostName = 'nansoft.co';

const String tokenUrl =
    "http://nansoft.co:89/IntegradorWerU/IntegradorWERU.svc/REST/MaestroToken";
const String masterUrl =
    "http://nansoft.co:89/IntegradorWerU/IntegradorWERU.svc/REST/DescargarArchivoMaestros";
const String appRibGetMessagesUrlHost = 'nansoft.co:87';
const String appRibGetMessagesUrlPath =
    '/PruebaWeruC/RibWeb.svc/REST/QueHayNuevo/';
const String appRibSetMessageReceivedUrlMethod =
    '/PruebaWeruC/RibWeb.svc/REST/ReportarMensajeRecibido/';
const String appRibSendMessageEntrada =
    '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStream';
const String appRibSendMessageSalida =
    '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStreamSalida';
const String appRibDeleteMessagesNewInstall =
    '/PruebaWeruC/RibWeb.svc/REST/BorrarMensajesTableta/';
const String sendImagesUrlMethod =
    'http://nansoft.co:87/PruebaWeruC/RibWeb.svc/REST/RecibirImagen';

const String appRibSleepTime = '2000';
const String appRibSleepTimeGPS = '1000';
const String appItemTypeInternalId = 'maq';

Future<String> getLocalDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();

  return Platform.isAndroid
      ? "/data/data/com.weru.weru/files"
      : "${directory.path}";
}

Future<String> getLocalCachePath() async {
  final directory = await getTemporaryDirectory();

  return Platform.isAndroid
      ? "/data/data/com.weru.weru/cache"
      : "${directory.path}";
}

Future<String> getLocalDatabasePathFile() async {
  final databasePath = await getLocalDatabasePath();
  return Platform.isAndroid
      ? "/data/data/com.weru.weru/files/weru.db"
      : "$databasePath/weru.db";
}

Future<String> getLocalMasterPath(String value) async {
  final directory = await getApplicationDocumentsDirectory();

  return Platform.isAndroid
      ? "/data/data/com.weru.weru/files/MasterData$value.zip"
      : "${directory.path}/MasterData$value.zip";
}

final String localDirectoryPath = "/data/data/com.weru.weru/files/MasterData";
