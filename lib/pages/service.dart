import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/cliente.dart';
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/estadoservicio.dart';
import 'package:weru/database/models/falla.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/tiposervicio.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/functions/get_status_color.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';
import 'dart:convert';
import 'package:weru/pages/menu.dart';
import 'package:weru/pages/more_info.dart';
import 'package:weru/pages/news.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late DatabaseMain databaseMain;
  late Session session;
  late int statusServiceId;
  late int statusServiceIdMenu;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio servicio;
  late Database database;

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
    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
      statusServiceId = databaseMain.services[index].idEstadoServicio;
      statusServiceIdMenu = statusServiceId;
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
        header: "Servicio",
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
                    const AppStatus(),
                    serviceMainSection(),
                    serviceMiddleSection(),
                    serviceEndedSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column serviceMainSection() {
    final service = databaseMain.services[index];
    final client = (index < databaseMain.clients.length &&
            databaseMain.clients[index] != null)
        ? databaseMain.clients[index]!
        : Cliente.unknown();
    final servicesStatus = (index < databaseMain.servicesStatus.length &&
            databaseMain.servicesStatus[index] != null)
        ? databaseMain.servicesStatus[index]!
        : EstadoServicio.unknown();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: statusServiceIdMenu == 3 ? 200 : 150,
            child: Container(
              height: statusServiceIdMenu == 3 ? 200 : 150,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TextUi(text: 'N° Servicio: ${service.consecutivo}'),
                  ),
                  const SizedBox(height: 10),
                  statusServiceIdMenu == 3
                      ? Container(
                          color: getStatusColor(servicesStatus.nombre),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 2, 30, 2),
                                child: TextUi(
                                  text: servicesStatus.nombre,
                                  color: Colors.white,
                                  main: true,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  Container(
                    color: const Color.fromARGB(255, 0, 45, 168),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                          child: TextUi(
                            text: 'Datos del cliente',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const DividerUi(paddingHorizontal: 0),
                  const SizedBox(height: 10),
                  Row(children: [
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          "assets/icons/pen-solid.svg",
                          width: 40,
                          height: 40,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF03a9f4),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextUi(text: 'Dirección: ${service.direccion}'),
                          TextUi(text: 'Establecimiento: ${service.nombre}'),
                          TextUi(text: 'Telefono: ${client.celular}'),
                          TextUi(text: 'Celular: ${client.celular}'),
                        ])
                  ]),
                ],
              ),
            )),
      ],
    );
  }

  Column serviceMiddleSection() {
    final service = databaseMain.services[index];
    final type = (index < databaseMain.servicesTypes.length &&
            databaseMain.servicesTypes[index] != null)
        ? databaseMain.servicesTypes[index]!
        : TipoServicio.unknown();

    final fail =
        (index < databaseMain.fails.length && databaseMain.fails[index] != null)
            ? databaseMain.fails[index]!
            : Falla.unknown();
    final equipment = (index < databaseMain.equipments.length &&
            databaseMain.equipments[index] != null)
        ? databaseMain.equipments[index]!
        : Equipo.unknown();
    final dateTime = service.fechayhorainicio.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: statusServiceIdMenu == 3 ? 250 : 200,
          child: Container(
            height: statusServiceIdMenu == 3 ? 250 : 200,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  color: const Color.fromARGB(255, 0, 45, 168),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                        child: TextUi(
                          text: 'Datos del servicio',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const DividerUi(paddingHorizontal: 0),
                const SizedBox(height: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      TextUi(text: 'Fecha: ${dateTime[0]}'),
                      const SizedBox(width: 30),
                      TextUi(text: 'Hora: ${dateTime[1]}'),
                    ],
                  ),
                  Row(
                    children: [
                      TextUi(text: 'N° Servicio: ${service.consecutivo}'),
                      const SizedBox(width: 59),
                      TextUi(
                        text: 'Radicado: ${service.radicado}',
                        long: 20,
                      )
                    ],
                  ),
                  TextUi(
                    text: 'Tipo de servicio: ${type.descripcion}',
                    long: 50,
                  ),
                  TextUi(
                    text: 'Establecimiento: ${service.nombre}',
                    long: 50,
                  ),
                  TextUi(text: 'Falla: ${fail.descripcion}'),
                  TextUi(text: 'Observación: ${service.observacionReporte}'),
                ]),
                const SizedBox(height: 10),
                statusServiceIdMenu == 3
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: const Color.fromARGB(255, 0, 45, 168),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                                  child: TextUi(
                                    text: 'Datos del equipo',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const DividerUi(paddingHorizontal: 0),
                          const SizedBox(height: 10),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextUi(
                                  text: 'Serial: ${equipment.serial}',
                                  long: 50,
                                ),
                                TextUi(
                                  text: 'Nombre: ${equipment.nombre}',
                                  long: 50,
                                ),
                              ]),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column serviceEndedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statusServiceIdMenu == 3
            ? Center(
                child: Column(
                children: [
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 200,
                    child: ButtonUi(
                      value: "Mas informacion",
                      onClicked: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoreInfoPage(),
                          ),
                        );
                      },
                      color: const Color.fromARGB(255, 66, 153, 149),
                      borderRadius: 2,
                    ),
                  ),
                ],
              ))
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ButtonUi(
                          value: statusServiceId == 2 || statusServiceId == 4
                              ? "Llegada a sitio"
                              : "Inicio",
                          onClicked: () async {
                            if (statusServiceId == 10) {
                              final Map<String, dynamic> serviceData =
                                  databaseMain.services[index].toMap();
                              serviceData['idEstadoServicio'] = 3;
                              serviceData['fechayhorainicio'] =
                                  DateTime.now().toString().substring(0, 19);
                              serviceData['fechaInicio'] =
                                  DateTime.now().toString().substring(0, 19);
                              final Servicio servicio =
                                  Servicio.fromMap(serviceData);
                              await servicioProvider.insert(servicio);
                              await onConnectionValidationStage(
                                  jsonEncode(servicio.toMap()), "Servicio");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MenuPage(),
                                ),
                              );
                            } else {
                              final Map<String, dynamic> serviceData =
                                  databaseMain.services[index].toMap();
                              serviceData['idEstadoServicio'] = 10;
                              serviceData['fechaLlegada'] =
                                  DateTime.now().toString().substring(0, 19);
                              final Servicio servicio =
                                  Servicio.fromMap(serviceData);
                              await servicioProvider.insert(servicio);
                              await onConnectionValidationStage(
                                  jsonEncode(servicio.toMap()), "Servicio");
                              setState(() {
                                statusServiceId = servicio.idEstadoServicio;
                              });
                            }
                          },
                          borderRadius: 2,
                          color: statusServiceId == 2 || statusServiceId == 4
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: ButtonUi(
                          value: "Cancelar",
                          onClicked: () async {
                            Navigator.pop(context);
                          },
                          color: Colors.red,
                          borderRadius: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width / 1.99),
                      const TextUi(
                        text: 'Novedades: ',
                        fontSize: 15,
                      ),
                      Expanded(
                        child: ButtonUi(
                          value: "+",
                          onClicked: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewsPage(),
                              ),
                            )
                          },
                          color: const Color.fromARGB(255, 244, 177, 54),
                          borderRadius: 20,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              )
      ],
    );
  }
}
