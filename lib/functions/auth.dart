import 'package:sqflite/sqflite.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/models/tecnico.dart';
import 'package:weru/provider/session.dart';

Future<bool> Auth(Session session, String username, String password) async {
  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  List<Tecnico> tecnicos = await TecnicoProvider(db: database).getAll();

  if (tecnicos.isNotEmpty) {
    Tecnico tecnico = tecnicos.first;
    if (username == tecnico.usuario && password == tecnico.clave) {
      await session.login(username, password);
      return true;
    }
  }
  return false;
}
