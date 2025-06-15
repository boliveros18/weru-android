import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/fotoservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/fotoservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PhotographPage extends StatefulWidget {
  const PhotographPage({super.key});

  @override
  State<PhotographPage> createState() => _PhotographPageState();
}

class _PhotographPageState extends State<PhotographPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  final picker = ImagePicker();
  XFile? pickedFile = null;
  String TextFieldValue = "";
  late List<FotoServicio> fotosServicio;
  final TextEditingController _textController = TextEditingController();

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
    await databaseMain.getPhotosService(service.id);
    fotosServicio = await databaseMain.photosServices;
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
        header: "Fotografia",
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [AppStatus(), Section()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: TextUi(
                text: 'N° Servicio: ${service.consecutivo}',
              ),
            ),
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        pickedFile != null
                            ? Image.file(
                                File(pickedFile!.path),
                                width: 80,
                                height: 80,
                              )
                            : SvgPicture.asset(
                                "assets/icons/gallery.svg",
                                width: 80,
                                height: 80,
                                colorFilter: const ColorFilter.mode(
                                  Color.fromARGB(255, 202, 202, 202),
                                  BlendMode.srcIn,
                                ),
                              ),
                        const SizedBox(height: 13),
                        ButtonUi(
                          value: "Foto",
                          onClicked: () async {
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 25,
                            );

                            if (pickedFile != null) {
                              final File rotatedImage =
                                  await FlutterExifRotation.rotateImage(
                                      path: pickedFile.path);

                              setState(() {
                                this.pickedFile = XFile(rotatedImage.path);
                              });
                            }
                          },
                          color: const Color(0xff4caf50),
                          borderRadius: 2,
                          fontSize: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: Colors.amber,
                          child: TextFieldUi(
                              hint: "Escribe un comentario",
                              minLines: 5,
                              regular: false,
                              onChanged: (value) => TextFieldValue = value,
                              controller: _textController),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 140,
                          child: ButtonUi(
                            value: "Agregar",
                            onClicked: () async {
                              if (pickedFile != null) {
                                final String fileFolder =
                                    '${await getLocalDatabasePath()}/backup';
                                final Directory backupDir =
                                    Directory(fileFolder);
                                if (!await backupDir.exists()) {
                                  await backupDir.create(recursive: true);
                                }
                                final String date = DateFormat("yyyyMMddHHmmss")
                                    .format(DateTime.now());
                                final String name =
                                    "Servicio_${service.id}_Foto-$date.png";
                                final String filePath =
                                    '${await getLocalDatabasePath()}/backup/${name}';
                                await pickedFile!.saveTo(filePath);
                                final cachePath =
                                    '${await getLocalCachePath()}/${pickedFile!.name}';
                                await File(cachePath).delete();
                                FotoServicio fotoservicio = FotoServicio(
                                    idServicio: service.id,
                                    archivo: filePath,
                                    comentario: TextFieldValue.isEmpty
                                        ? "..."
                                        : TextFieldValue);
                                await FotoServicioProvider(db: database)
                                    .insert(fotoservicio);
                                await databaseMain.getPhotosService(service.id);
                                pickedFile = null;
                                _textController.clear();
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              }
                            },
                            color: const Color(0xff4caf50),
                            borderRadius: 2,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
                "Lista de fotos agregadas (${databaseMain.photosServices.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.photosServices.length) {
                            final _new = databaseMain.photosServices[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Image.file(
                                      File(_new.archivo),
                                      width: 40,
                                      height: 40,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 10),
                                          TextUi(
                                            text:
                                                'Comentario: ${_new.comentario}',
                                            fontSize: 15,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.09,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          onPressed: () async {
                                            try {
                                              await FotoServicioProvider(
                                                      db: database)
                                                  .delete(_new.id!);
                                              var file = File(_new.archivo);
                                              await file.delete();
                                              await databaseMain
                                                  .getPhotosService(service.id);
                                              setState(() {});
                                            } catch (e) {
                                              print("Error al eliminar: $e");
                                            }
                                          },
                                          icon: SvgPicture.asset(
                                            "assets/icons/trash-can-regular.svg",
                                            width: 27,
                                            height: 27,
                                            colorFilter: ColorFilter.mode(
                                              const Color.fromARGB(
                                                  255, 255, 118, 108),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                DividerUi(
                                  paddingHorizontal: 0,
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: databaseMain.photosServices.length,
                      )),
                )
              ],
            ),
            if (isLoading) const ProgressIndicatorUi()
          ],
        ),
      ],
    );
  }
}
