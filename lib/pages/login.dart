import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/functions/response_stage_message_xml_to_json.dart';
import 'package:weru/functions/insert_master_file_in_sqflite.dart';
import 'package:weru/functions/insert_stage_message_list_data_to_sqflite.dart';
import 'package:weru/functions/auth.dart';
import 'package:weru/provider/session.dart';
import 'package:weru/permission_request.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool permissionsGranted = false;
  late bool master;
  bool isTimerInitialized = false;
  late Session session;
  final FTPService ftpService = FTPService();
  late Timer timer;
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  late Database database;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iOsInfo;
  bool success = false;

  @override
  void initState() {
    super.initState();
    session = Provider.of<Session>(context, listen: false);
    session.loadSession();
    _initializeApp();
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    if (isTimerInitialized) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!permissionsGranted)
                    PermissionRequest(
                      onPermissionStatusChanged: updatePermissionStatus,
                    ),
                  GestureDetector(
                    onTap: () async {
                      if (Platform.isAndroid) {
                        androidInfo = await deviceInfo.androidInfo;
                      } else {
                        iOsInfo = await deviceInfo.iosInfo;
                      }
                      DialogUi.show(
                        context: context,
                        title:
                            "Este es el id del dispositivo: ${Platform.isAndroid ? androidInfo.id : iOsInfo.identifierForVendor}",
                        textField: false,
                        onConfirm: (value) async {},
                      );
                    },
                    child: Image.asset('assets/icons/weru.png'),
                  ),
                  const SizedBox(height: 20),
                  TextFieldUi(
                    hint: "Usuario",
                    prefixIcon: true,
                    prefixIconPath: "assets/icons/user.png",
                    controller: userController,
                    onChanged: (value) => session.user = value,
                    regular: false,
                  ),
                  const SizedBox(height: 20),
                  TextFieldUi(
                    pass: true,
                    hint: "Contraseña",
                    prefixIcon: true,
                    prefixIconPath: "assets/icons/padlock.png",
                    controller: passController,
                    onChanged: (value) => session.pass = value,
                    regular: false,
                  ),
                  const SizedBox(height: 20),
                  ButtonUi(
                      value: "Ingresar",
                      onClicked: () async {
                        bool validation = await Auth(
                            session, userController.text, passController.text);
                        if (validation) {
                          await session.login(
                              userController.text, passController.text);
                        } else {
                          (Future.delayed(Duration.zero, () {
                            DialogUi.show(
                              context: context,
                              title: "Contraseña o usuario invalido!",
                              textField: false,
                              onConfirm: (value) async {},
                            );
                          }));
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updatePermissionStatus(bool granted) {
    if (mounted) {
      setState(() {
        permissionsGranted = granted;
      });
    }
  }

  Future<void> downloadAndUnzipMaster(String value) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Descargando archivo..."),
            ],
          ),
        );
      },
    );
    master = await ftpService.downloadFile(value);
    if (master) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Archivo master descargado!")),
      );
      final input = InputFileStream(await getLocalMasterPath(value));
      final archive = await ZipDecoder().decodeStream(input);
      for (final file in archive) {
        if (file.isFile) {
          try {
            final output =
                OutputFileStream('${localDirectoryPath}/${file.name}');
            output.writeStream(file.getContent()!);
            insertMasterFileInSqflite(file, database);
            await file.close();
          } catch (e, stackTrace) {
            print('Error in file:${e}, $stackTrace');
          }
        } else {
          try {
            await Directory('${localDirectoryPath}/${file.name}')
                .create(recursive: true);
          } catch (e, stackTrace) {
            print('Error in directory:${e}, $stackTrace');
          }
        }
      }
      await ftpService.deleteMessagesNewInstall();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nit errado")),
      );
    }
  }

  Future<void> _initializeApp() async {
    await currentPosition();
    database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        if (!Directory(localDirectoryPath).existsSync()) {
          DialogUi.show(
            context: context,
            title: "Ingrese el nit de la organización",
            hintText: "nit",
            cancel: false,
            onConfirm: (value) async {
              if (Platform.isAndroid) {
                androidInfo = await deviceInfo.androidInfo;
              } else {
                iOsInfo = await deviceInfo.iosInfo;
              }
              await downloadAndUnzipMaster(value);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Por favor espere..."),
                      ],
                    ),
                  );
                },
              );
              try {
                String response = await FTPService.getMessages();
                if (response.isEmpty) {
                  return;
                }
                final data = await responseStageMessageXMLtoJSON(response);
                if (data.isNotEmpty) {
                  await insertStageMessageListDataToSqflite(data, database);
                }
              } catch (e, stackTrace) {
                print(
                    'Error in getting initials new data master: $e, $stackTrace');
              } finally {
                Navigator.of(context, rootNavigator: true).pop();
              }
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  DialogUi.show(
                    context: context,
                    title:
                        "Este es el id del dispositivo: ${Platform.isAndroid ? androidInfo.id : iOsInfo.identifierForVendor}",
                    textField: false,
                    onConfirm: (value) async {},
                  );
                }
              });
            },
          );
        }
      }
    });
    bool isDialogVisible = false;
    timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      try {
        String response = await FTPService.getMessages();
        if (response.isEmpty) {
          return;
        }
        final data = await responseStageMessageXMLtoJSON(response);
        if (data['Tecnico'] != null &&
            data['Tecnico'] is List &&
            data['Tecnico']!.isNotEmpty &&
            data['Tecnico']![0]['usuario']?.toString().isNotEmpty == true) {
          bool insert =
              await insertStageMessageListDataToSqflite(data, database);
          if (insert && !isDialogVisible) {
            isDialogVisible = true;
            Future.delayed(Duration.zero, () {
              DialogUi.show(
                context: context,
                title:
                    "Se descargaron tus servicios y credenciales. Accede a tu cuenta!",
                textField: false,
                onConfirm: (value) async {
                  isDialogVisible = false;
                },
              );
            });
          }
        }
      } catch (e, stackTrace) {
        print('Error in _initializeApp: $e, $stackTrace');
      }
    });
    isTimerInitialized = true;
  }
}

Future<Position> currentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  late LocationSettings locationSettings;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 5),
    );
  }
  if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.other,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
    );
  }

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await _showLocationServiceDialog();
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  Position position = await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );

  return position;
}

Future<void> _showLocationServiceDialog() async {
  return showDialog<void>(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
            'Please enable location services in your device settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
