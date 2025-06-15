import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class FTPService {
  Future<bool> downloadFile(String value) async {
    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'text/plain',
          'Accept': '*/*',
        },
        body: jsonEncode({"NIT": value, "Aplicacion": "PWeruC"}),
      );
      if (response.statusCode == 200) {
        final String data = response.body;
        String tokenData = jsonDecode(data);
        final res = await http.post(
          Uri.parse(masterUrl),
          headers: {
            'Content-Type': 'text/plain',
            'Accept': '*/*',
          },
          body: jsonDecode(jsonEncode(tokenData)),
        );
        if (res.headers['content-disposition'] ==
            "attachment; filename=MasterData.zip") {
          final file = File(await getLocalMasterPath(value));
          await file.writeAsBytes(res.bodyBytes);
          return true;
        } else {
          print("Error in master post: ${res.statusCode} - ${res.body}");
          return false;
        }
      } else {
        print("Error in token post: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error al descargar el archivo: $e');
      return false;
    }
  }

  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late String id;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iOsInfo = await deviceInfo.iosInfo;
      id = iOsInfo.identifierForVendor ?? '';
    }
    return id;
  }

  static Future<String> getMessages() async {
    try {
      final idDevice = await getDeviceId();
      final uri = Uri.http(
        appRibGetMessagesUrlHost,
        appRibGetMessagesUrlPath + idDevice,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Error al obtener mensajes: ${response.statusCode}');
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static Future<void> setMessageReceived(String idStageMessage) async {
    try {
      final idDevice = await getDeviceId();
      final response = await http.get(
        Uri.http(
            appRibGetMessagesUrlHost,
            appRibSetMessageReceivedUrlMethod +
                idDevice +
                "/" +
                idStageMessage),
      );
      if (response.statusCode != 200) {
        print(
            'Error al reportar mensaje recibido: ${response.statusCode}, ${idStageMessage}');
      }
    } catch (e) {}
  }

  static Future<bool> sendMessageEntrada(
      String body, String table, String date) async {
    final idNegocio = DateFormat("yyyyMMddHHmmss")
        .format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(date));
    final idDevice = await getDeviceId();
    final Map<String, dynamic> data = {
      "familiaMensaje": table,
      "tipoMensaje": "INSERT",
      "mensaje": body,
      "keyDispositivo": idDevice,
      "idNegocio": idNegocio
    };
    final formData = data.entries.map((e) {
      return '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}';
    }).join('&');

    final response = await http.post(
      Uri.http(appRibGetMessagesUrlHost, appRibSendMessageEntrada),
      headers: {"Content-Type": "text/plain"},
      body: formData,
    );

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final idEvento = document
          .findAllElements("IdEvento")
          .map((node) => node.innerText)
          .join();
      if (idEvento == "0") {
        return true;
      } else {
        return false;
      }
    } else {
      print('Error al enviar mensaje de entrada: ${response.statusCode}');
      return false;
    }
  }

  static Future<void> sendMessageSalida(String message) async {
    final response = await http.post(
      Uri.http(appRibGetMessagesUrlHost, appRibSendMessageSalida),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de salida enviado');
    } else {
      print('Error al enviar mensaje de salida: ${response.statusCode}');
    }
  }

  Future<void> deleteMessagesNewInstall() async {
    final idDevice = await getDeviceId();
    final uri = Uri.http(
      appRibGetMessagesUrlHost,
      appRibDeleteMessagesNewInstall + idDevice,
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      print('Mensajes borrados');
    } else {
      print('Error al borrar mensajes: ${response.statusCode}');
    }
  }

  static Future<void> sendImage(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      print('El archivo no existe: $imagePath');
      return;
    }

    final fileName = file.path.split('/').last;
    final boundary =
        '----DartFormBoundary${DateTime.now().millisecondsSinceEpoch}';
    final contentType = 'multipart/form-data; boundary=$boundary';
    final body = <int>[];
    void write(String s) => body.addAll(s.codeUnits);

    write('--$boundary\r\n');
    write(
        'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n');
    write('Content-Type: image/png\r\n\r\n');
    body.addAll(await file.readAsBytes());
    write('\r\n--$boundary--\r\n');

    final uri = Uri.parse(sendImagesUrlMethod);
    final request = await HttpClient().postUrl(uri)
      ..headers.set(HttpHeaders.contentTypeHeader, contentType)
      ..headers.set(HttpHeaders.contentLengthHeader, body.length)
      ..add(body);

    try {
      final response = await request.close();
      if (response.statusCode == 200) {
        await file.delete();
      } else {
        print('Error al enviar la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción durante el envío: $e');
    }
  }
}
