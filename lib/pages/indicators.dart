import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/dropdown_menu_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/indicador.dart';
import 'package:weru/database/models/indicadormodelo.dart';
import 'package:weru/database/models/indicadorservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/indicador_provider.dart';
import 'package:weru/database/providers/indicadormodelo_provider.dart';
import 'package:weru/database/providers/indicadorservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class IndicatorsPage extends StatefulWidget {
  const IndicatorsPage({super.key});

  @override
  State<IndicatorsPage> createState() => _IndicatorPageState();
}

class _IndicatorPageState extends State<IndicatorsPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Indicador> indicators;

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
    await databaseMain.getIndicators(service.id, service.idTecnico);
    indicators = await filteredIndicators(service.idEquipo);

    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
    });
  }

  Future<List<Indicador>> filteredIndicators(int idEquipo) async {
    final Equipo equipo =
        await EquipoProvider(db: database).getItemById(idEquipo);

    final idModelo = equipo.idModelo;

    final List<IndicadorModelo> _indicadorModelo =
        await IndicadorModeloProvider(db: database).getAllByIdModelo(idModelo);

    final fetchedIndicators = await Future.wait(
      _indicadorModelo.map((indicator) async {
        try {
          return await IndicadorProvider(db: database)
              .getItemById(indicator.idIndicador);
        } catch (_) {
          return null;
        }
      }),
    );

    return fetchedIndicators.whereType<Indicador>().toList();
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
        header: "Indicadores",
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
              hint: "Valor",
              textfield: true,
              list: indicators.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Indicador",
              onConfirm: (id, value) async {
                bool isEqual = await databaseMain.indicatorsServices
                    .any((_new) => _new.idIndicador == id);
                if (!isEqual) {
                  IndicadorServicio indicatorServices = IndicadorServicio(
                      idIndicador: id,
                      idServicio: service.id,
                      idTecnico: service.idTecnico,
                      valor: value);
                  await IndicadorServicioProvider(db: database)
                      .insert(indicatorServices);
                  await databaseMain.getIndicators(
                      service.id, service.idTecnico);
                  setState(() {});
                }
              },
            ),
            Text(
                "2. Lista de agregados (${databaseMain.indicatorsServices.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.indicatorsServices.length) {
                            final _new =
                                (index < databaseMain.indicatorsServices.length)
                                    ? databaseMain.indicatorsServices[index]
                                    : IndicadorServicio.unknown();
                            final _indicator =
                                databaseMain.indicators.firstWhere(
                              (item) => item.id == _new.idIndicador,
                              orElse: () => Indicador.unknown(),
                            );
                            return GestureDetector(
                                onTap: () {
                                  (Future.delayed(Duration.zero, () {
                                    DialogUi.show(
                                      hintText: "Valor",
                                      context: context,
                                      title:
                                          'Edita el campo de valor de este item: ${_indicator.descripcion}',
                                      textField: true,
                                      onConfirm: (value) async {
                                        Map<String, Object?> indicatorItem =
                                            _new.toMap();
                                        indicatorItem['valor'] = value;
                                        IndicadorServicio updated =
                                            IndicadorServicio.fromMap(
                                                indicatorItem);
                                        await IndicadorServicioProvider(
                                                db: database)
                                            .update(updated);
                                        await databaseMain.getIndicators(
                                            service.id, service.idTecnico);
                                        setState(() {});
                                      },
                                    );
                                  }));
                                },
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
                                              SizedBox(height: 5),
                                              TextUi(
                                                  text:
                                                      'Código: ${_indicator.id}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Nombre: ${_indicator.descripcion}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text: 'Valor: ${_new.valor}',
                                                  fontSize: 15),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                                    await IndicadorServicioProvider(
                                                            db: database)
                                                        .deleteByIdIndicador(
                                                            _new.idIndicador,
                                                            service.id,
                                                            service.idTecnico);
                                                    await databaseMain
                                                        .getIndicators(
                                                            service.id,
                                                            service.idTecnico);
                                                    setState(() {});
                                                  } catch (e) {
                                                    print(
                                                        "Error al eliminar: $e");
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
                                    DividerUi(
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
                        itemCount: databaseMain.indicatorsServices.length,
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
