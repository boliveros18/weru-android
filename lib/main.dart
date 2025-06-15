import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:weru/functions/current_situation.dart';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/login.dart';
import 'package:weru/provider/session.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:weru/functions/insert_stage_message_list_data_to_sqflite.dart';
import 'package:weru/functions/response_stage_message_xml_to_json.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/main.dart';
import 'package:weru/config/config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weru/database/providers/pulso_provider.dart';
import 'package:weru/database/models/pulso.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/models/tecnico.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:weru/services/stage_service.dart';
import 'package:flutter/services.dart';
import 'package:weru/services/notification_services.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
const MethodChannel backgroundChannel = MethodChannel('background_channel');
bool? lastInternetStatus;
bool? lastGpsStatus;
bool permissionsGranted = false;
final session = Session();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  await checkAndRequestPermissions();
  await initializeService();
  startBackgroundService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Session> _initializeSession() async {
    await session.loadSession();
    return session;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session>(
      future: _initializeSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return ChangeNotifierProvider<Session>.value(
          value: snapshot.data!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Poppins'),
            home: Consumer<Session>(
              builder: (context, session, _) {
                return session.isAuthenticated
                    ? const HomePage()
                    : const LoginPage();
              },
            ),
          ),
        );
      },
    );
  }
}

Future<void> checkAndRequestPermissions() async {
  LocationPermission locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
  }

  permission.PermissionStatus cameraPermission =
      await permission.Permission.camera.status;
  if (cameraPermission.isDenied) {
    cameraPermission = await permission.Permission.camera.request();
  }

  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      var managePermission =
          await permission.Permission.manageExternalStorage.status;
      if (managePermission.isDenied) {
        await permission.Permission.manageExternalStorage.request();
      }
    } else {
      var storagePermission = await permission.Permission.storage.status;
      if (storagePermission.isDenied) {
        await permission.Permission.storage.request();
      }
    }
  }

  permission.PermissionStatus phonePermission =
      await permission.Permission.phone.status;
  if (phonePermission.isDenied) {
    phonePermission = await permission.Permission.phone.request();
  }

  if (await permission.Permission.notification.isDenied) {
    await permission.Permission.notification.request();
  }
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future<void> pulseStageInsert(
    Database database,
    Tecnico updated,
    double latitud,
    double longitud,
    String fechaPulso,
    String situacionActual) async {
  await PulsoProvider(db: database).insert(Pulso(
      idTecnico: updated.id,
      latitud: latitud,
      longitud: longitud,
      fechaPulso: fechaPulso,
      situacionActual: situacionActual));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "",
      content: "",
    );
  }
  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process is now stopped");
  });

  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();

  DatabaseMain databaseMain = DatabaseMain(path: await getLocalDatabasePath());

  final ReceivePort waitPort = ReceivePort();
  IsolateNameServer.removePortNameMapping('onstart_service_port');
  IsolateNameServer.registerPortWithName(
      waitPort.sendPort, 'onstart_service_port');

  String deviceName;
  String platformVersion;

  LocationSettings locationSettings;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 10),
    );
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceName = androidInfo.model;
    platformVersion =
        RegExp(r'(\d+\.\d+\.\d+)').firstMatch(Platform.version)?.group(1) ??
            "Not Found";
  } else if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.other,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
    );
    IosDeviceInfo iOsInfo = await deviceInfo.iosInfo;
    deviceName = iOsInfo.modelName;
    platformVersion =
        RegExp(r'(\d+\.\d+\.\d+)').firstMatch(Platform.version)?.group(1) ??
            "Not Found";
  } else {
    print('Plataforma no soportada para obtener ubicaciones.');
    return;
  }

  waitPort.listen((message) {
    if (message == "ready") {
      Timer.periodic(const Duration(seconds: 30), (timer) async {
        Stopwatch stopwatch = Stopwatch()..start();
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        bool currentInternetStatus =
            connectivityResult.contains(ConnectivityResult.mobile) ||
                connectivityResult.contains(ConnectivityResult.wifi);

        if (lastInternetStatus != currentInternetStatus) {
          lastInternetStatus = currentInternetStatus;
          if (currentInternetStatus) {
            await currentSituation("ModoAvion-Desactivado");
          } else {
            await currentSituation("ModoAvion-Activado");
          }
        }

        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          if (lastInternetStatus != true) {
            await currentSituation("Señal-Activada");
          }
        } else if (connectivityResult.contains(ConnectivityResult.none)) {
          if (lastInternetStatus != false) {
            await currentSituation("Señal-Desactivada");
          }
        }

        Geolocator.getServiceStatusStream()
            .listen((ServiceStatus status) async {
          bool gpsEnabled = (status == ServiceStatus.enabled);

          if (!gpsEnabled) {
            showNotification("GPS desactivado:", "Por favor, active su gps");
          }

          if (lastGpsStatus != gpsEnabled) {
            lastGpsStatus = gpsEnabled;
            await currentSituation(
                gpsEnabled ? "Gps-Activado" : "Gps-Desactivado");
          }
        });
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          );
        } catch (e) {
          showNotification("Error obteniendo posición GPS:", "$e");
        }

        if (position == null) {
          return;
        }

        final double latitud = position.latitude;
        final double longitud = position.longitude;

        final String fechaPulso =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        final String versionApp =
            '4.1 ${Platform.isAndroid ? "- SDK:" : "- iOs:"} ${platformVersion} - Equipo: ${deviceName}';
        if (!Directory(await getLocalDatabasePathFile()).existsSync()) {
          await session.loadSession();
          int id =
              await TecnicoProvider(db: database).getItemIdByUser(session.user);
          Tecnico technicians =
              await TecnicoProvider(db: database).getItemById(id);

          if (technicians.usuario != "") {
            Map<String, Object?> technician = technicians.toMap();
            technician['latitud'] = latitud;
            technician['longitud'] = longitud;
            technician['fechaPulso'] = fechaPulso;
            technician['versionApp'] = versionApp;
            Tecnico updated = Tecnico.fromMap(technician);
            TecnicoProvider(db: database).insert(updated);

            if (currentInternetStatus) {
              try {
                String message = await FTPService.getMessages();
                if (message.isNotEmpty) {
                  final data = await responseStageMessageXMLtoJSON(message);
                  if ((data['Error'] as List).isEmpty) {
                    await insertStageMessageListDataToSqflite(data, database);
                    if (data['Servicio']!.isNotEmpty) {
                      await session.loadSession();
                      await databaseMain.setUser(session.user);
                      await databaseMain.getServices();
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate(duration: 500);
                      }
                      showNotification("Nuevo servicio",
                          "Recientemente acaba de llegar un nuevo servicio desde WerU.");
                      SendPort? uiSendPort =
                          IsolateNameServer.lookupPortByName('service_port');
                      if (uiSendPort != null) {
                        uiSendPort.send("Servicio");
                      }
                    }
                  } else {
                    SendPort? uiSendPort =
                        IsolateNameServer.lookupPortByName('service_port');
                    if (uiSendPort != null) {
                      uiSendPort.send(data['Error']);
                    }
                    if (await Vibration.hasVibrator()) {
                      Vibration.vibrate(duration: 500);
                    }
                    showNotification("Error",
                        "Error en el nuevo servicio desde WerU. Error en mensaje entrante de la familia: ${data['Error']}");
                  }
                }

                await FTPService.sendMessageEntrada(
                    jsonEncode(technician), 'Tecnico', fechaPulso);
                await StageService.sendStageMessages2Server();

                List<Pulso> pulses = await PulsoProvider(db: database).getAll();
                if (pulses.isNotEmpty) {
                  for (final pulse in pulses) {
                    if (stopwatch.elapsed.inSeconds >= 28) {
                      break;
                    }
                    technician['latitud'] = pulse.latitud;
                    technician['longitud'] = pulse.longitud;
                    technician['fechaPulso'] = pulse.fechaPulso;
                    technician['situacionActual'] = pulse.situacionActual;
                    bool sent = await FTPService.sendMessageEntrada(
                        jsonEncode(technician), 'Tecnico', pulse.fechaPulso);
                    await Future.delayed(const Duration(seconds: 1));
                    if (sent) {
                      await PulsoProvider(db: database).delete(pulse.id!);
                    }
                  }
                }
              } catch (e) {
                if (e.toString().contains("Connection timed out") ||
                    e.toString().contains("Failed host lookup")) {
                  await currentSituation("Señal-Desactivada");
                  await pulseStageInsert(database, updated, latitud, longitud,
                      fechaPulso, "Señal-Desactivada");
                }
              }
            } else {
              try {
                await currentSituation("ModoAvion-Activado");
                await pulseStageInsert(database, updated, latitud, longitud,
                    fechaPulso, "ModoAvion-Activado");
              } catch (e) {
                print('Error al insertar pulso: $e');
              }
            }
          }
        }
        stopwatch.stop();
      });
    }
  });
}
