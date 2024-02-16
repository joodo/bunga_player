import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'alist.dart';
import 'bilibili.dart';
import 'bunga.dart';
import 'chat.dart';
import 'chat.stream_io.dart';
import 'call.dart';
import 'call.agora.dart';
import 'player.dart';
import 'player.media_kit.dart';
import 'preferences.dart';
import 'toast.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton<Preferences>(await Preferences.create());
  getIt.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  getIt.registerSingleton<Toast>(Toast());
  getIt.registerSingleton<Player>(MediaKitPlayer());
}

Future<void> initHost(String host) async {
  final bungaService = Bunga(host);
  final appKey = AppKey.fromJson(await bungaService.getAppKey());

  getIt.registerSingleton<Bunga>(bungaService);
  getIt.registerSingleton<ChatService>(StreamIO(appKey.streamIO));
  getIt.registerSingleton<CallService>(Agora(appKey.agora));
  getIt.registerSingleton<AList>(AList());
  getIt.registerSingleton<Bilibili>(Bilibili());
}

void unregisterHost() {
  getIt.unregister<Bunga>();
  getIt.unregister<ChatService>();
  getIt.unregister<CallService>();
  getIt.unregister<AList>();
  getIt.unregister<Bilibili>();
}
