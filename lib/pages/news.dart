import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/dropdown_menu_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/novedad.dart';
import 'package:weru/database/models/novedadservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/novedad_provider.dart';
import 'package:weru/database/providers/novedadservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'dart:convert';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late DatabaseMain databaseMain;
  late Session session;
  late int statusServiceId;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio servicio;
  late Database database;
  late List<Novedad> novedades;
  late List<NovedadServicio> novedadesServicio;

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
    servicio = databaseMain.services[index];
    await databaseMain.getNews(servicio.id);
    novedades = await NovedadProvider(db: database).getAll();
    novedadesServicio = databaseMain.newsServices;

    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
      statusServiceId = servicio.idEstadoServicio;
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
        header: "Novedades",
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            DropdownMenuUi(
              list: novedades.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Novedad",
              onConfirm: (id, value) async {
                bool isEqual = databaseMain.newsServices
                    .any((_new) => _new.idNovedad == id);
                if (!isEqual) {
                  NovedadServicio novedadServicio = NovedadServicio(
                    idServicio: servicio.id,
                    idNovedad: id,
                  );
                  await NovedadServicioProvider(db: database)
                      .insert(novedadServicio);
                  await onConnectionValidationStage(
                    jsonEncode(novedadServicio.toMap()),
                    "NovedadServicio",
                  );
                  await databaseMain.getNews(servicio.id);
                  final Map<String, dynamic> serviceData =
                      databaseMain.services[index].toMap();
                  serviceData['idEstadoServicio'] = 4;
                  final Servicio service = Servicio.fromMap(serviceData);
                  await servicioProvider.insert(service);
                  await onConnectionValidationStage(
                      jsonEncode(service.toMap()), "Servicio");
                  setState(() {});
                }
              },
            ),
            Text("2. Lista de agregados (${databaseMain.news.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.news.length) {
                            final _new = (index < databaseMain.news.length)
                                ? databaseMain.news[index]
                                : Novedad.unknown();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 5),
                                          TextUi(
                                              text: 'Código: ${_new.id}',
                                              fontSize: 15),
                                          TextUi(
                                              text:
                                                  'Nombre: ${_new.descripcion}',
                                              fontSize: 15),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                await NovedadServicioProvider(
                                                        db: database)
                                                    .deleteByIdNovedadAndIdServicio(
                                                        _new.id, servicio.id);
                                                await databaseMain
                                                    .getNews(servicio.id);
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
                                        )),
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
                        itemCount: databaseMain.news.length,
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
