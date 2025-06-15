import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/tecnico.dart';
import 'package:weru/database/providers/fotoservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:weru/pages/home.dart';
import 'package:signature/signature.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:weru/components/text_ui.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late DatabaseMain databaseMain;
  late Session session;
  TextEditingController nameController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController idController = TextEditingController();
  String TextFieldName = "";
  String TextFieldComment = "";
  String TextFieldId = "";
  int index = 0;
  bool isLoading = true;
  late SignatureController signatureController;
  late ServicioProvider servicioProvider;
  int diagnosesLength = 0;
  late Servicio service;
  late Database database;
  late Map<String, Object?> message;

  @override
  void initState() {
    super.initState();
    session = Provider.of<Session>(context, listen: false);
    index = session.indexServicio;
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    databaseMain = DatabaseMain(path: await getLocalDatabasePath());
    database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    await databaseMain.setUser(session.user);
    await databaseMain.getServices();
    service = databaseMain.services[index];
    final String fileFolder = '${await getLocalDatabasePath()}/backup';
    final Directory backupDir = Directory(fileFolder);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    await databaseMain.getNews(service.id);
    await databaseMain.getDiagnoses(service.id);
    await databaseMain.getActivities(service.id);
    await databaseMain.getRefills(service.id);
    await databaseMain.getOverheads(service.id);
    await databaseMain.getPhotosService(service.id);
    await databaseMain.getIndicators(service.id, service.idTecnico);
    final client = databaseMain.clients[index]!.toMap();
    final equipment = databaseMain.equipments[index]!.toMap();
    final newServices =
        databaseMain.newsServices.map((item) => item.toMap()).toList();
    final diagnosesServices =
        databaseMain.diagnosesServices.map((item) => item.toMap()).toList();
    diagnosesLength = diagnosesServices.length;
    final activitiesServices =
        databaseMain.activitiesServices.map((item) => item.toMap()).toList();
    final itemServices =
        databaseMain.refillsServices.map((item) => item.toMap()).toList();
    final overheadServices =
        databaseMain.overheadsServices.map((item) => item.toMap()).toList();
    final photoServices =
        databaseMain.photosServices.map((item) => item.toMap()).toList();
    final parserphotoServices = photoServices.map((item) {
      return {
        ...item,
        'archivo': (item['archivo'] as String?)?.split('/').last ?? '',
      };
    }).toList();
    final indicatorServices =
        databaseMain.indicatorsServices.map((item) => item.toMap()).toList();
    message = {
      "Cliente": client,
      "Equipo": equipment,
      "NovedadServicio": newServices,
      "DiagnosticoServicio": diagnosesServices,
      "ActividadServicio": activitiesServices,
      "ItemServicio": itemServices,
      "IndirectoServicio": overheadServices,
      "FotoServicio": parserphotoServices,
      "IndicadorServicio": indicatorServices,
    };

    signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: const Color.fromARGB(255, 0, 0, 0),
      exportBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
      exportPenColor: Colors.black,
      onDrawStart: () => FocusScope.of(context).unfocus(),
    );
    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: ProgressIndicatorUi(),
        ),
      );
    }
    return Scaffold(
      appBar: const AppBarUi(
        header: "Firma",
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatus(),
                    MainSection(),
                    MiddleSection(),
                    EndedSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column MainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: 292,
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TextUi(
                      text: 'N° Servicio: ${service.consecutivo}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFieldUi(
                      hint: "Nombre ",
                      regular: false,
                      onChanged: (value) => TextFieldName = value,
                      controller: nameController),
                  const SizedBox(height: 20),
                  Container(
                    color: Colors.amber,
                    child: TextFieldUi(
                        hint: "Escribe un comentario...",
                        minLines: 4,
                        regular: false,
                        onChanged: (value) => TextFieldComment = value,
                        controller: commentController),
                  ),
                  const SizedBox(height: 20),
                  TextFieldUi(
                      isNumeric: true,
                      hint: "Cedula ",
                      regular: false,
                      onChanged: (value) => TextFieldId = value,
                      controller: idController),
                  const SizedBox(height: 20),
                ],
              ),
            )),
      ],
    );
  }

  Column MiddleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 250, 250),
                    border: Border.all(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        width: 1),
                  ),
                  child: Signature(
                      key: const Key('signature'),
                      controller: signatureController,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      height: 180)),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                child: ButtonUi(
                  value: "Limpiar",
                  onClicked: () async {
                    setState(() => signatureController.clear());
                  },
                  color: const Color.fromARGB(255, 241, 241, 241),
                  borderRadius: 2,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column EndedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
            child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: ButtonUi(
                disabled: service.idEstadoServicio == 5 ? true : false,
                value: service.idEstadoServicio == 5 ? "Enviado " : "Enviar",
                onClicked: () async {
                  final Uint8List? signature = await signatureController
                      .toPngBytes(height: 250, width: 500);
                  final fields = TextFieldName.isNotEmpty &&
                      TextFieldComment.isNotEmpty &&
                      TextFieldId.isNotEmpty &&
                      signature != Null &&
                      signature!.isNotEmpty;

                  if (fields) {
                    if (diagnosesLength != 0) {
                      final String date =
                          DateFormat("yyyyMMddHHmmss").format(DateTime.now());
                      final String name =
                          "Servicio_${service.id}_Firma-$date.png";
                      final String filePath =
                          '${await getLocalDatabasePath()}/backup/$name';
                      final File img = File(filePath);
                      await img.writeAsBytes(signature);
                      int id = await TecnicoProvider(db: database)
                          .getItemIdByUser(session.user);
                      Tecnico technicians =
                          await TecnicoProvider(db: database).getItemById(id);
                      Map<String, Object?> technician = technicians.toMap();
                      final String datef = DateFormat("yyyy-MM-dd HH:mm:ss")
                          .format(DateTime.now());
                      bool send = await FTPService.sendMessageEntrada(
                          jsonEncode(technician), 'Tecnico', datef);
                      Map<String, Object?> serviceItem = service.toMap();
                      serviceItem['latitud'] = technicians.latitud;
                      serviceItem['longitud'] = technicians.longitud;
                      serviceItem['nombreFirma'] = TextFieldName;
                      serviceItem['comentarios'] = TextFieldComment;
                      serviceItem['cedulaFirma'] = TextFieldId;
                      serviceItem['archivoFirma'] = img.path;
                      serviceItem['fechaModificacion'] =
                          DateTime.now().toString().substring(0, 19);
                      Servicio updated = Servicio.fromMap(serviceItem);
                      await servicioProvider.update(updated);
                      await databaseMain.getServices();
                      service = databaseMain.services[index];
                      FocusScope.of(context).unfocus();
                      if (send) {
                        await databaseMain.getPhotosService(service.id);
                        final photoServices = databaseMain.photosServices
                            .map((item) => item.toMap())
                            .toList();
                        if (photoServices.isNotEmpty) {
                          for (final photo in photoServices) {
                            final String? filePath =
                                photo["archivo"] as String?;
                            final int id = photo["id"] as int;
                            if (filePath != null && filePath.isNotEmpty) {
                              await FTPService.sendImage(filePath);
                              await FotoServicioProvider(db: database)
                                  .delete(id);
                            } else {
                              print("Archivo no válido: $filePath");
                            }
                          }
                        }
                        await FTPService.sendImage(service.archivoFirma);
                        Map<String, Object?> serviceItem = service.toMap();
                        serviceItem['idEstadoServicio'] = 5;
                        serviceItem['fechaModificacion'] =
                            DateTime.now().toString().substring(0, 19);
                        serviceItem['fechaFin'] =
                            DateTime.now().toString().substring(0, 19);
                        serviceItem['archivoFirma'] =
                            service.archivoFirma.split('/').last;
                        Servicio updated = Servicio.fromMap(serviceItem);
                        await servicioProvider.update(updated);
                        service = updated;
                        onConnectionValidationStage(
                            jsonEncode({...message, ...service.toMap()}),
                            "ServicioFlutter");
                        nameController.clear();
                        commentController.clear();
                        idController.clear();
                        signatureController.clear();
                        setState(() {});
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    } else {
                      MessageAlert(
                          'Debes agregar algún diagnóstico en el menú de servicios para poder firmar.');
                    }
                  } else {
                    MessageAlert('Rellena los campos y la firma');
                  }
                },
                color: service.idEstadoServicio == 5
                    ? const Color.fromARGB(255, 228, 228, 228)
                    : const Color(0xff4caf50),
                textColor:
                    service.idEstadoServicio == 5 ? Colors.black : Colors.white,
                borderRadius: 2,
              ),
            ),
          ],
        ))
      ],
    );
  }

  void MessageAlert(String text) {
    (Future.delayed(Duration.zero, () {
      DialogUi.show(
        textField: false,
        context: context,
        title: text,
        onConfirm: (value) async {},
      );
    }));
  }
}
