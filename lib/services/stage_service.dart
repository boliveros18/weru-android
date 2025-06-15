import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/models/stagemessage.dart';
import 'package:weru/database/providers/stagemessage_provider.dart';
import 'package:weru/database/main.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:intl/intl.dart';

class StageService {
  StageService();

  static Future<Database> database() async {
    return await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  }

  static Future<void> sendStageMessages2Server() async {
    List<StageMessage> items =
        await StageMessageProvider(db: await database()).getAll();
    final now = DateTime.now();

    for (final item in items) {
      String message = item.Message;
      String table = item.MessageFamily;
      if (item.Sent == 1) {
        final difference =
            now.difference(DateTime.parse(item.CreatedAt)).inDays;
        if (difference > 7) {
          StageMessageProvider(db: await database()).delete(item.id!);
        }
      } else {
        final String date =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        bool sent = await FTPService.sendMessageEntrada(
            jsonEncode(message), table, date);
        Map<String, Object?> stageMessage = item.toMap();
        stageMessage['Sent'] = sent ? 1 : 0;
        StageMessage updated = StageMessage.fromMap(stageMessage);
        await StageMessageProvider(db: await database()).update(updated);
      }
    }
  }
}
