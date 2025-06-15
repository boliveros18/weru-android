import 'dart:ui';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/ciudad.dart';
import 'package:weru/database/models/cliente.dart';
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/estadoservicio.dart';
import 'package:weru/database/models/modelo.dart';
import 'package:weru/functions/get_status_color.dart';
import 'package:weru/pages/menu.dart';
import 'package:weru/pages/service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'dart:isolate';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseMain databaseMain;
  late Session session;
  bool isLoading = true;
  final ReceivePort _receivePort = ReceivePort();

  @override
  void initState() {
    super.initState();
    session = Provider.of<Session>(context, listen: false);
    session.loadSession();
    initializeDatabase();
    IsolateNameServer.removePortNameMapping('service_port');
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      'service_port',
    );
    _receivePort.listen((message) async {
      if (message is String && message == "Servicio") {
        await databaseMain.setUser(session.user);
        await databaseMain.getServices();
        setState(() {});
      }
      if (message is Map<String, dynamic>) {
        final latitude = message["latitude"];
        final longitude = message["longitude:"];
        final fecha = message["date"];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lat: $latitude, Lon: $longitude, Fecha: $fecha"),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    });

    SendPort? onStartPort = IsolateNameServer.lookupPortByName(
      'onstart_service_port',
    );
    if (onStartPort != null) {
      onStartPort.send("ready");
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('service_port');
    super.dispose();
  }

  Future<void> initializeDatabase() async {
    databaseMain = DatabaseMain(path: await getLocalDatabasePath());
    await databaseMain.setUser(session.user);
    await databaseMain.getServices();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: ProgressIndicatorUi()));
    }
    return Scaffold(
      appBar: const AppBarUi(
        header: "Servicios",
        prefixIcon: true,
        prefixIconHeight: 34,
        prefixIconWidth: 34,
        prefixIconPath: "assets/icon/icon.svg",
        centerTitle: false,
        menuIcon: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const AppStatus(), servicesSection()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column servicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 85,
          child: ListView.separated(
            itemBuilder: (context, index) {
              final service = databaseMain.services[index];
              final client = (index < databaseMain.clients.length &&
                      databaseMain.clients[index] != null)
                  ? databaseMain.clients[index]!
                  : Cliente.unknown();

              final city = (index < databaseMain.cities.length &&
                      databaseMain.cities[index] != null)
                  ? databaseMain.cities[index]!
                  : Ciudad.unknown();

              final equipment = (index < databaseMain.equipments.length &&
                      databaseMain.equipments[index] != null)
                  ? databaseMain.equipments[index]!
                  : Equipo.unknown();

              final model = (index < databaseMain.models.length &&
                      databaseMain.models[index] != null)
                  ? databaseMain.models[index]!
                  : Modelo.unknown();

              final status = (index < databaseMain.servicesStatus.length &&
                      databaseMain.servicesStatus[index] != null)
                  ? databaseMain.servicesStatus[index]!
                  : EstadoServicio.unknown();

              final dateAndTime = service.fechaInicio.split(' ');
              final address = "${service.direccion}${city.nombre}";
              final encodedAddress = Uri.encodeComponent(address);
              final googleMapsUrl =
                  "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
              final statusColor = getStatusColor(status.nombre);

              return Container(
                height: 180,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border(
                    left: BorderSide(color: statusColor, width: 7),
                    bottom: BorderSide(color: statusColor, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(googleMapsUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          print("No se pudo abrir Google Maps");
                        }
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          SvgPicture.asset(
                            "assets/icons/google-maps.svg",
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await session.setIndexService(index);
                        if (databaseMain.services[index].idEstadoServicio ==
                                10 ||
                            databaseMain.services[index].idEstadoServicio ==
                                2 ||
                            databaseMain.services[index].idEstadoServicio ==
                                4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServicePage(),
                            ),
                          ).then(
                            (value) async => {
                              await databaseMain.getServices(),
                              setState(() {}),
                            },
                          );
                        } else if (databaseMain
                                .services[index].idEstadoServicio ==
                            3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MenuPage()),
                          ).then(
                            (value) async => {
                              await databaseMain.getServices(),
                              setState(() {}),
                            },
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              TextUi(
                                  text: 'N° Servicio: ${service.consecutivo}'),
                              const SizedBox(width: 15),
                              TextUi(
                                text: 'Radicado: ${service.radicado}',
                                long: 20,
                              ),
                            ],
                          ),
                          TextUi(text: 'Cliente: ${client.nombre}'),
                          TextUi(text: 'Dirección: ${service.direccion}'),
                          TextUi(text: 'Ubicación: ${city.nombre}'),
                          TextUi(text: 'Equipo: ${equipment.nombre}'),
                          TextUi(text: 'Serial: ${equipment.serial}'),
                          TextUi(text: 'Modelo: ${model.descripcion}'),
                          Row(
                            children: [
                              TextUi(text: 'Fecha: ${dateAndTime[0]}'),
                              const SizedBox(width: 8),
                              TextUi(text: 'Hora: ${dateAndTime[1]}'),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            color: statusColor,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                              child: TextUi(
                                text: status.nombre,
                                color: Colors.white,
                                main: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemCount: databaseMain.services.length,
          ),
        ),
      ],
    );
  }
}
