import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/menu_item_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/pages/activity.dart';
import 'package:weru/pages/diagnosis.dart';
import 'package:weru/pages/indicators.dart';
import 'package:weru/pages/overhead.dart';
import 'package:weru/pages/photograph.dart';
import 'package:weru/pages/refills.dart';
import 'package:weru/pages/service.dart';
import 'package:weru/pages/signature.dart';
import 'package:weru/pages/tools.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
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
    await databaseMain.setUser(session.user);
    await databaseMain.getServices();
    setState(() {
      isLoading = false;
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
          header: "Menu",
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        const AppStatus(),
                        serviceHeaderSection(),
                        serviceBodySection()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Column serviceHeaderSection() {
    service = databaseMain.services[index];
    return Column(
      children: [
        const SizedBox(height: 10),
        TextUi(text: 'N° Servicio: ${service.consecutivo}'),
        const SizedBox(height: 20),
        Container(
          color: const Color.fromARGB(255, 0, 45, 168),
          child: const Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                child: TextUi(
                  text: 'PANEL DE CONTROL',
                  color: Colors.white,
                  main: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Column serviceBodySection() {
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuItemUi(
                IconPath: "assets/icons/servicio.png",
                title: "Servicio",
                page: ServicePage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/diagnosticos.png",
                title: "Diagnosticos",
                page: DiagnosisPage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/actividades.png",
                title: "Actividades",
                page: ActivityPage()),
          ],
        ),
        SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuItemUi(
                IconPath: "assets/icons/repuestos.png",
                title: "Repuestos",
                page: RefillsPage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/herramientas.png",
                title: "Herramientas",
                page: ToolsPage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/indirectos.png",
                title: "Indirectos",
                page: OverheadPage()),
          ],
        ),
        SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuItemUi(
                IconPath: "assets/icons/fotografia.png",
                title: "Fotografia",
                page: PhotographPage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/indicador.png",
                title: "Indicadores",
                page: IndicatorsPage()),
            SizedBox(width: 10),
            MenuItemUi(
                IconPath: "assets/icons/pencil.png",
                title: "Firmar-cerrar",
                page: SignaturePage()),
          ],
        ),
      ],
    );
  }
}
