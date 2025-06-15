import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _user = "";
  String _pass = "";
  int _indexServicio = 0;
  bool _isAuthenticated = false;

  String get user => _user;
  String get pass => _pass;
  int get indexServicio => _indexServicio;
  bool get isAuthenticated => _isAuthenticated;

  set user(String value) {
    _user = value;
  }

  set pass(String value) {
    _pass = value;
  }

  Future<void> loadSession() async {
    _user = await _storage.read(key: 'user') ?? "";
    _pass = await _storage.read(key: 'pass') ?? "";
    _indexServicio =
        int.tryParse(await _storage.read(key: 'idServicio') ?? "0") ?? 0;
    _isAuthenticated = _user.isNotEmpty && _pass.isNotEmpty;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _user = username;
    _pass = password;
    await _storage.write(key: 'user', value: _user);
    await _storage.write(key: 'pass', value: _pass);
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = "";
    _pass = "";
    _indexServicio = 0;
    _isAuthenticated = false;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<void> setIndexService(int value) async {
    _indexServicio = value;
    await _storage.write(key: 'idServicio', value: _indexServicio.toString());
    notifyListeners();
  }
}
