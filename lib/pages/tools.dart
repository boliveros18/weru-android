import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Item> tools = [];

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
    if (databaseMain.services.isNotEmpty) {
      service = databaseMain.services[index];
      await databaseMain.getTools(service.id);
      tools = databaseMain.tools;
    }
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
        header: "Heramientas",
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
          children: [
            const SizedBox(height: 10),
            Center(
              child: TextUi(
                text: 'N° Servicio: ${service.consecutivo}',
              ),
            ),
            const SizedBox(height: 10),
            Text("Lista de herramientas (${tools.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < tools.toList().length) {
                            final _new = tools[index];
                            return GestureDetector(
                                onTap: () {},
                                child: Column(
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
                                              const SizedBox(height: 5),
                                              TextUi(
                                                  text: 'Código: ${_new.id}',
                                                  fontSize: 15),
                                              TextUi(
                                                  long: 42,
                                                  text:
                                                      'Nombre: ${_new.descripcion}',
                                                  fontSize: 15),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const DividerUi(
                                      paddingHorizontal: 0,
                                    ),
                                  ],
                                ));
                          } else {
                            return Container();
                          }
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: tools.toList().length,
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
