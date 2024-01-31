import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser(this._context) {
    final pref = getService<Preferences>();

    _name = pref.get<String>('user_name');

    String? prefID = pref.get<String>('client_id');
    if (prefID == null) {
      prefID = const Uuid().v4();
      pref.set('client_id', prefID);
    }
    _id = prefID;

    login().onError((error, stackTrace) {
      _context.showToast('登录失败');
      logger.e('Login failed: $error');
    });
  }
  final BuildContext _context;

  late String _id;
  String get id => _id;

  String? _name;
  String? get name => _name;

  late String _token;
  String get token => _token;

  bool __isOnline = false;
  bool get isOnline => __isOnline;
  set _isOnline(bool newValue) {
    if (newValue == __isOnline) return;
    __isOnline = newValue;
    notifyListeners();
  }

  Future<void> login() async {
    final bungaService = getService<Bunga>();
    _token = await bungaService.userLogin(_id);

    final chatService = getService<StreamIO>();
    await chatService.login(_id, _token, _name);
    _isOnline = true;
  }

  Future<void> logout() async {
    final chatService = getService<StreamIO>();
    await chatService.logout();
    _isOnline = false;
  }

  Future<void> rename(String newName) async {
    if (newName == _name) return;

    _name = newName;
    getService<Preferences>().set('user_name', newName);

    final chatService = getService<StreamIO>();
    await chatService.updateUserInfo(this);

    notifyListeners();
  }

  Future<void> changeID(String newID) async {
    if (_id == newID) return;

    await logout();

    _id = newID;
    await login();
  }

  @override
  String toString() {
    return 'id: $id\nname: $name\ntoken: $token';
  }
}
