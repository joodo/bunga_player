import 'package:bunga_player/models/app_key/app_key.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'agora.dart';
import 'alist.dart';
import 'bilibili.dart';
import 'bunga.dart';
import 'stream_io.dart';
import 'preferences.dart';
import 'toast.dart';

final getService = GetIt.instance;

Future<void> init() async {
  getService.registerSingleton<Preferences>(await Preferences.create());
  getService.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  getService.registerSingleton<Toast>(Toast());
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
