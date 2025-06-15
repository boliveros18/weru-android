import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'dart:io';

Future<void> FactoryModelsAndProviders() async {
  try {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final modelsPath = p.join(documentsDirectory.path, 'database/models');
    final providersPath = p.join(documentsDirectory.path, 'database/providers');
    final tables = await rootBundle.loadString('assets/utils/tables.sql');
    final tableRegex = RegExp(r'(\w+)\s*\(([^)]+)\)');
    final matches = tableRegex.allMatches(tables);

    for (final match in matches) {
      final tableName = match.group(1)!;
      final columns = match.group(2)!.split(',');
      final className = _capitalize(tableName);
      final fields = columns.map((col) {
        final parts = col.trim().split(' ');
        final fieldName = parts[0];
        final fieldType = _mapSqlTypeToDartType(parts[1]);
        return '  final $fieldType $fieldName;';
      }).join('\n');

      final modelConstructor = columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        return '    required this.$fieldName,';
      }).join('\n');

      final toMapEntries = columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        return "      '$fieldName': $fieldName,";
      }).join('\n');

      final fromMapEntries = columns.map((col) {
        final parts = col.trim().split(' ');
        final fieldName = parts[0];
        final sqlType = parts[1];
        final dartType = _mapSqlTypeToDartType(sqlType);
        if (dartType == 'int') {
          return "      $fieldName: int.tryParse(map['$fieldName']?.toString() ?? '') ?? 0,";
        } else if (dartType == 'double') {
          return "      $fieldName: double.tryParse(map['$fieldName']?.toString() ?? '') ?? 0.0,";
        } else if (dartType == 'DateTime') {
          return "      $fieldName: DateTime.tryParse(map['$fieldName']?.toString() ?? '') ?? DateTime(0),";
        } else {
          return "      $fieldName: map['$fieldName']?.toString() ?? '',";
        }
      }).join('\n');

      final modelContent = '''
class $className {
$fields

  $className({
$modelConstructor
  });

  Map<String, Object?> toMap() {
    return {
$toMapEntries
    };
  }

   factory   $className.fromMap(Map<String, dynamic> map) {
    return   $className(
     $fromMapEntries
    );
  }

  @override
  String toString() {
    return '$className{${columns.map((col) => col.trim().split(' ')[0] + ': \$' + col.trim().split(' ')[0]).join(', ')}}';
  }
}
''';

      final modelFile =
          File(p.join(modelsPath, '${tableName.toLowerCase()}.dart'));
      await modelFile.create(recursive: true);
      await modelFile.writeAsString(modelContent);

      final providerContent = '''
import 'package:sqflite/sqflite.dart';
import '../models/${tableName.toLowerCase()}.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ${className}Provider {

  final Database db;
  ${className}Provider({required this.db});

  Future<void> insert($className ${tableName.toLowerCase()}) async {
    await db.insert(
      '$tableName',
      ${tableName.toLowerCase()}.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

   Future<$className> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      '$className',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de $className no encontrado!');
    }
    return $className.fromMap(items.first);
  }

  Future<List<$className>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('$tableName');
    return maps.map((map) {
      return $className(
      ${columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        final fieldType = _mapSqlTypeToDartType(col.trim().split(' ')[1]);
        return "        $fieldName: map['$fieldName'] as $fieldType,";
      }).join('\n')}
      );
    }).toList();
  }

  Future<void> update($className ${tableName.toLowerCase()}) async {
    await db.update(
      '$tableName',
      ${tableName.toLowerCase()}.toMap(),
      where: 'id = ?',
      whereArgs: [${tableName.toLowerCase()}.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      '$tableName',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

Future<void> insertInitFile(ArchiveFile file) async {
  List<int> bytes = file.content;
  String fileContent = utf8.decode(bytes);
  List<String> lines = fileContent.split('\\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      $className ${tableName.toLowerCase()} = $className(
          ${columns.map((col) {
        final parts = col.trim().split(' ');
        final fieldName = parts[0];
        final fieldType = _mapSqlTypeToDartType(parts[1]);
        if (fieldType == "String") {
          return "$fieldName: parts[${columns.indexOf(col)}].trim(),";
        } else {
          return "$fieldName: $fieldType.parse(parts[${columns.indexOf(col)}].trim()),";
        }
      }).join('\n')}
        );
      await db.transaction((database) async {
        await database.insert(
          '$tableName',
          ${tableName.toLowerCase()}.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
''';

      final providerFile = File(
          p.join(providersPath, '${tableName.toLowerCase()}_provider.dart'));
      await providerFile.create(recursive: true);
      await providerFile.writeAsString(providerContent);
    }
  } catch (e) {
    print('Error generating models and providers:${e}');
  }
}

String _capitalize(String input) {
  return input[0].toUpperCase() + input.substring(1);
}

String _mapSqlTypeToDartType(String sqlType) {
  final type = sqlType.toUpperCase();
  if (type.startsWith('DECIMAL')) {
    return 'double';
  }
  switch (type) {
    case 'INTEGER':
      return 'int';
    case 'INT':
      return 'int';
    case 'TEXT':
      return 'String';
    case 'REAL':
      return 'double';
    case 'DATETIME':
      return 'DateTime';
    default:
      return 'Object';
  }
}
