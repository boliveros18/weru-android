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
import 'package:weru/database/models/equipo.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/itemmodelo.dart';
import 'package:weru/database/models/itemservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/itemmodelo_provider.dart';
import 'package:weru/database/providers/itemservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:weru/components/dialog_ui.dart';

class RefillsPage extends StatefulWidget {
  const RefillsPage({super.key});

  @override
  State<RefillsPage> createState() => _RefillsPageState();
}

class _RefillsPageState extends State<RefillsPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Item> refills;

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
    await databaseMain.getRefills(service.id);
    refills = await filteredRefills(service.idEquipo);

    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
    });
  }

  Future<List<Item>> filteredRefills(int idEquipo) async {
    final Equipo equipo =
        await EquipoProvider(db: database).getItemById(idEquipo);

    final idModelo = equipo.idModelo;

    final List<ItemModelo> _itemModelo =
        await ItemModeloProvider(db: database).getAllByIdModelo(idModelo);

    print(_itemModelo);

    final fetchedRefills = await Future.wait(
      _itemModelo.map((item) async {
        try {
          return await ItemProvider(db: database).getItemById(item.idItem);
        } catch (_) {
          return null;
        }
      }),
    );

    return fetchedRefills.whereType<Item>().toList();
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
        header: "Repuestos",
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
              list: refills.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Repuesto",
              onConfirm: (id, value) async {
                if (int.tryParse(value) != null) {
                  Item refill =
                      await ItemProvider(db: database).getItemById(id);
                  bool isEqual = await databaseMain.refillsServices
                      .any((_new) => _new.idItem == id);
                  if (!isEqual) {
                    ItemServicio refillService = ItemServicio(
                        idServicio: service.id,
                        idItem: id,
                        cantidad: double.tryParse(value.trim()) ?? 0.0,
                        valor: refill.precio,
                        costo: refill.costo,
                        cantidadReq: double.tryParse(value.trim()) ?? 0.0,
                        fechaUltimaVez: "",
                        vidaUtil: "");
                    await ItemServicioProvider(db: database)
                        .insert(refillService);
                    await databaseMain.getRefills(service.id);
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
            Text(
                "2. Lista de agregados (${databaseMain.refillsServices.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 40,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.refillsServices.length) {
                            final _new =
                                (index < databaseMain.refillsServices.length)
                                    ? databaseMain.refillsServices[index]
                                    : ItemServicio.unknown();
                            final _refill = databaseMain.refills.firstWhere(
                              (item) => item.id == _new.idItem,
                              orElse: () => Item.unknown(),
                            );
                            return GestureDetector(
                                onTap: () {
                                  (Future.delayed(Duration.zero, () {
                                    DialogUi.show(
                                      hintText: "Cantidad",
                                      context: context,
                                      title:
                                          'Edita el campo de cantidad de este item: ${_refill.descripcion}',
                                      textField: true,
                                      onConfirm: (value) async {
                                        if (int.tryParse(value) != null) {
                                          Map<String, Object?> refillItem =
                                              _new.toMap();
                                          refillItem['cantidad'] = value;
                                          ItemServicio updated =
                                              ItemServicio.fromMap(refillItem);
                                          await ItemServicioProvider(
                                                  db: database)
                                              .update(updated);
                                          await databaseMain
                                              .getRefills(service.id);
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
                                              SizedBox(height: 5),
                                              TextUi(
                                                  text:
                                                      'Código: ${_new.idItem}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Nombre: ${_refill.descripcion}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Cantidad requerida: ${_new.cantidadReq}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Ultima aplicacion: ${_new.fechaUltimaVez}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Vida Util: ${_new.vidaUtil}',
                                                  fontSize: 15),
                                              TextUi(
                                                  text:
                                                      'Cantidad: ${_new.cantidad}',
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
                                                    await ItemServicioProvider(
                                                            db: database)
                                                        .delete(_new.id!);
                                                    await databaseMain
                                                        .getRefills(service.id);
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
                                ));
                          } else {
                            return Container();
                          }
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: databaseMain.refillsServices.length,
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
