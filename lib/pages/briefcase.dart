import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/maletin.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class BriefcasePage extends StatefulWidget {
  const BriefcasePage({super.key});

  @override
  State<BriefcasePage> createState() => _BriefcasePageState();
}

class _BriefcasePageState extends State<BriefcasePage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Item> tools = [];
  late List<Maletin> briefcase = [];

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
    if (databaseMain.services.isNotEmpty &&
        index < databaseMain.services.length) {
      service = databaseMain.services[index];
      await databaseMain.getItems(service.idTecnico);
      tools = await ItemProvider(db: database).getAllByType(2);
      briefcase = await databaseMain.briefcase;
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
        header: "Maletin",
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
            const SizedBox(height: 20),
            Column(
              children: [
                Container(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width - 40,
                        child: databaseMain.briefcase.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  if (index < databaseMain.briefcase.length) {
                                    final _new = databaseMain.tools[index];
                                    (index < databaseMain.tools.length)
                                        ? databaseMain.tools[index]
                                        : Item.unknown();
                                    final _tool =
                                        databaseMain.briefcase.firstWhere(
                                      (item) => item.idItem == _new.id,
                                      orElse: () => Maletin.unknown(),
                                    );
                                    return GestureDetector(
                                        onTap: () {},
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      TextUi(
                                                          text:
                                                              'Código: ${_new.SKU}',
                                                          fontSize: 14),
                                                      TextUi(
                                                          long: 42,
                                                          text:
                                                              'Descripcion: ${_new.descripcion}',
                                                          fontSize: 14),
                                                      TextUi(
                                                          text:
                                                              'Cantidad: ${_tool.cantidad}',
                                                          fontSize: 14),
                                                      const SizedBox(
                                                          height: 10),
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
                                itemCount: databaseMain.briefcase.length,
                              )
                            : const Text("No hay items en el maletin... ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16))))
              ],
            ),
            if (isLoading) const ProgressIndicatorUi()
          ],
        ),
      ],
    );
  }
}
