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
import 'package:weru/database/models/indirecto.dart';
import 'package:weru/database/models/indirectomodelo.dart';
import 'package:weru/database/models/indirectoservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/indirecto_provider.dart';
import 'package:weru/database/providers/indirectomodelo_provider.dart';
import 'package:weru/database/providers/indirectoservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class OverheadPage extends StatefulWidget {
  const OverheadPage({super.key});

  @override
  State<OverheadPage> createState() => _OverheadPageState();
}

class _OverheadPageState extends State<OverheadPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Indirecto> overheads;

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
    await databaseMain.getOverheads(service.id);
    overheads = await filteredOverheads(service.idEquipo);

    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
    });
  }

  Future<List<Indirecto>> filteredOverheads(int idEquipo) async {
    final Equipo equipo =
        await EquipoProvider(db: database).getItemById(idEquipo);

    final idModelo = equipo.idModelo;

    final List<IndirectoModelo> _indirectoModelo =
        await IndirectoModeloProvider(db: database).getAllByIdModelo(idModelo);

    final fetchedOverheads = await Future.wait(
      _indirectoModelo.map((overhead) async {
        try {
          return await IndirectoProvider(db: database)
              .getItemById(overhead.idIndirecto);
        } catch (_) {
          return null;
        }
      }),
    );

    return fetchedOverheads.whereType<Indirecto>().toList();
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
        header: "Indirectos",
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
              hint: "Cantidad",
              textfield: true,
              list: overheads.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Indirecto",
              onConfirm: (id, value) async {
                if (int.tryParse(value) != null) {
                  Indirecto overhead =
                      await IndirectoProvider(db: database).getItemById(id);
                  bool isEqual = await databaseMain.overheadsServices
                      .any((_new) => _new.idIndirecto == id);
                  if (!isEqual) {
                    IndirectoServicio overheadServices = IndirectoServicio(
                        idIndirecto: overhead.id,
                        idServicio: service.id,
                        cantidad: int.parse(value),
                        costo: overhead.costo.toInt(),
                        valor: overhead.valor.toInt());
                    await IndirectoServicioProvider(db: database)
                        .insert(overheadServices);
                    await databaseMain.getOverheads(service.id);
                    setState(() {});
                  }
                } else {
                  (Future.delayed(Duration.zero, () {
                    DialogUi.show(
                      textField: false,
                      context: context,
                      title: 'Escribe un numero valido!',
                      onConfirm: (value) async {},
                    );
                  }));
                }
              },
            ),
            Text("2. Lista de agregados (${databaseMain.overheads.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.overheads.length) {
                            final _new = (index < databaseMain.overheads.length)
                                ? databaseMain.overheads[index]
                                : Indirecto.unknown();
                            final _overhead =
                                databaseMain.overheadsServices.firstWhere(
                              (item) => item.idIndirecto == _new.id,
                              orElse: () => IndirectoServicio.unknown(),
                            );
                            return GestureDetector(
                                onTap: () {
                                  (Future.delayed(Duration.zero, () {
                                    DialogUi.show(
                                      hintText: "Cantidad",
                                      context: context,
                                      title:
                                          'Edita el campo de cantidad de este item: ${_new.descripcion}',
                                      textField: true,
                                      onConfirm: (value) async {
                                        if (int.tryParse(value) != null) {
                                          Map<String, Object?> overheadItem =
                                              _overhead.toMap();
                                          overheadItem['cantidad'] = value;
                                          IndirectoServicio updated =
                                              IndirectoServicio.fromMap(
                                                  overheadItem);
                                          await IndirectoServicioProvider(
                                                  db: database)
                                              .update(updated);
                                          await databaseMain
                                              .getOverheads(service.id);
                                          setState(() {});
                                        } else {
                                          (Future.delayed(Duration.zero, () {
                                            DialogUi.show(
                                              textField: false,
                                              context: context,
                                              title:
                                                  'Escribe un numero valido!',
                                              onConfirm: (value) async {},
                                            );
                                          }));
                                        }
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
                                              const SizedBox(height: 5),
                                              TextUi(
                                                  text: 'Código: ${_new.id}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Nombre: ${_new.descripcion}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Cantidad: ${_overhead.cantidad}',
                                                  fontSize: 15),
                                              const SizedBox(height: 10),
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
                                                    await IndirectoServicioProvider(
                                                            db: database)
                                                        .deleteByIdIndirectoAndIdServicio(
                                                            _new.id,
                                                            service.id);
                                                    await databaseMain
                                                        .getOverheads(
                                                            service.id);
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
                        itemCount: databaseMain.overheads.length,
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
