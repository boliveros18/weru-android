import 'package:sqflite/sqflite.dart';
import '../models/stagemessage.dart';

class StageMessageProvider {
  final Database db;
  StageMessageProvider({required this.db});

  Future<void> insert(String message, String table) async {
    final date = DateTime.now().toString().substring(0, 19);
    StageMessage stagemessage = StageMessage(
        Message: message,
        MessageFamily: table,
        Action: "INSERT",
        CreatedAt: date,
        Sent: 0);
    await db.insert(
      'StageMessage',
      stagemessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StageMessage> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'StageMessage',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de StageMessage no encontrado!');
    }
    return StageMessage.fromMap(items.first);
  }

  Future<List<StageMessage>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('StageMessage');
    return maps.map((map) {
      return StageMessage(
          id: map['id'] as int,
          Message: map['Message'] as String,
          MessageFamily: map['MessageFamily'] as String,
          Action: map['Action'] as String,
          CreatedAt: map['CreatedAt'] as String,
          Sent: map['Sent'] as int);
    }).toList();
  }

  Future<void> update(StageMessage stagemessage) async {
    await db.update(
      'StageMessage',
      stagemessage.toMap(),
      where: 'id = ?',
      whereArgs: [stagemessage.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'StageMessage',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
