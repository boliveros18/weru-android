import 'package:weru/database/providers/stagemessage_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/main.dart';
import 'package:weru/config/config.dart';
import 'package:intl/intl.dart';

Future<void> stageMessageProviderInsert(String message, String table) async {
  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  final stageMessageProvider = await StageMessageProvider(db: database);
  stageMessageProvider.insert(message, table);
}

Future<void> onConnectionValidationStage(String message, String table) async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi)) {
    try {
      final String date =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      await FTPService.sendMessageEntrada(message, table, date);
    } catch (e) {
      if (e.toString().contains("Connection timed out") ||
          e.toString().contains("Failed host lookup")) {
        await stageMessageProviderInsert(message, table);
      }
    }
  } else {
    await stageMessageProviderInsert(message, table);
  }
}
