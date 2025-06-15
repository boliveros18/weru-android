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
import 'package:weru/database/models/diagnostico.dart';
import 'package:weru/database/models/diagnosticoservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/diagnostico_provider.dart';
import 'package:weru/database/providers/diagnosticoservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Diagnostico> diagnoses;
  late List<DiagnosticoServicio> diagnosesService;

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
    await databaseMain.getDiagnoses(service.id);
    diagnoses = await DiagnosticoProvider(db: database).getAll();
    diagnosesService = databaseMain.diagnosesServices;
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
        header: "Diagnosticos",
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
            const SizedBox(height: 10),
            Center(
              child: TextUi(
                text: 'N° Servicio: ${service.consecutivo}',
              ),
            ),
            const SizedBox(height: 10),
            DropdownMenuUi(
              list: diagnoses.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Diagnostico",
              onConfirm: (id, value) async {
                bool isEqual = await databaseMain.diagnosesServices
                    .any((_new) => _new.idDiagnostico == id);
                if (!isEqual) {
                  DiagnosticoServicio diagnosisService = DiagnosticoServicio(
                    idServicio: service.id,
                    idDiagnostico: id,
                  );
                  await DiagnosticoServicioProvider(db: database)
                      .insert(diagnosisService);
                  await databaseMain.getDiagnoses(service.id);
                  setState(() {});
                }
              },
            ),
            Text("2. Lista de agregados (${databaseMain.diagnoses.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.diagnoses.length) {
                            final _new = (index < databaseMain.diagnoses.length)
                                ? databaseMain.diagnoses[index]
                                : Diagnostico.unknown();
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
                                                await DiagnosticoServicioProvider(
                                                        db: database)
                                                    .deleteByIdDiagnosticoAndIdServicio(
                                                        _new.id, service.id);
                                                await databaseMain
                                                    .getDiagnoses(service.id);
                                                setState(() {});
                                              } catch (e) {
                                                print("Error al eliminar: $e");
                                              }
                                            },
                                            icon: SvgPicture.asset(
                                              "assets/icons/trash-can-regular.svg",
                                              width: 27,
                                              height: 27,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                Color.fromARGB(
                                                    255, 255, 118, 108),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                                const DividerUi(
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
                        itemCount: databaseMain.diagnoses.length,
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
