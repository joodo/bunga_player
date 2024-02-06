import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:bunga_player/services/agora.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

final getService = GetIt.instance;

Future<void> init() async {
  getService.registerSingleton<Preferences>(await Preferences.create());
  getService.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
}

Future<void> initHost(String host) async {
  final bungaService = Bunga(host);
  final appKey = AppKey.fromJson(await bungaService.getAppKey());

  getService.registerSingleton<Bunga>(bungaService);
  getService.registerSingleton<StreamIO>(StreamIO(appKey.streamIO));
  getService.registerSingleton<Agora>(Agora(appKey.agora));
  getService.registerSingleton<AList>(AList());
  getService.registerSingleton<Bilibili>(Bilibili());
}

void unregisterHost() {
  getService.unregister<Bunga>();
  getService.unregister<StreamIO>();
  getService.unregister<Agora>();
  getService.unregister<Bilibili>();
}
