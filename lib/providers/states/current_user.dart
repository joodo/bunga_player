import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser() {
    final pref = getService<Preferences>();

    _name = pref.get<String>('user_name');

    String? prefID = pref.get<String>('client_id');
    if (prefID == null) {
      prefID = const Uuid().v4();
      pref.set('client_id', prefID);
    }
    _id = prefID;

    login().onError((error, stackTrace) {
      getService<Toast>().show('登录失败');
      logger.e('Login failed: $error');
    });
  }

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
    await chatService.updateUserName(_id, _name!);

    notifyListeners();
  }

  Future<void> changeID(String newID) async {
    if (_id == newID) return;

    await logout();

    _id = newID;
    await login();
  }

  ChannelData getSharingData(VideoEntry entry) {
    final currentUser = getService<StreamIO>().currentUser;
    assert(currentUser != null);

    return ChannelData(
      videoType: entry is LocalVideoEntry ? VideoType.local : VideoType.online,
      name: entry.title,
      videoHash: entry.hash,
      sharer: currentUser!,
    );
  }

  @override
  String toString() {
    return 'id: $id\nname: $name\ntoken: $token';
  }
}
