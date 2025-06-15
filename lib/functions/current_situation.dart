import 'package:sqflite/sqflite.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'dart:convert';
import 'package:weru/database/models/tecnico.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';

Future<void> currentSituation(state) async {
  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  List<Tecnico> technicians = await TecnicoProvider(db: database).getAll();
  if (technicians.isNotEmpty) {
    Map<String, Object?> technician = technicians[0].toMap();
    if (technician['situacionActual'] != state) {
      technician['situacionActual'] = state;
      final Tecnico tecnico = Tecnico.fromMap(technician);
      TecnicoProvider tecnicoProvider = TecnicoProvider(db: database);
      await tecnicoProvider.insert(tecnico);
      await onConnectionValidationStage(jsonEncode(tecnico.toMap()), "Tecnico");
    }
  }
}
