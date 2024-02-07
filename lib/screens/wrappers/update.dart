import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updat/updat.dart';
import 'package:updat/updat_window_manager.dart';
import 'package:http/http.dart' as http;

class UpdateWrapper extends StatelessWidget {
  final Widget child;

  const UpdateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final packageInfo = getService<PackageInfo>();
    return UpdatWindowManager(
      currentVersion: packageInfo.version,
      getLatestVersion: () async {
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/joodo/bunga_player/releases/latest",
        ));

        final latestVersion = jsonDecode(data.body)["tag_name"];
        logger.i(
            'Current version: ${packageInfo.version}, Latest version: $latestVersion');
        return latestVersion;
      },
      getBinaryUrl: (version) async {
        final data = await http.get(Uri.parse(
          "https://joodo.github.io/bunga_player/update/${Platform.operatingSystem}/binaryUrl.json",
        ));
        final url = jsonDecode(data.body)[version];
        logger.i('Latest version download url: \n$url');
        return url;
      },
      appName: "Bunga Player", // This is used to name the downloaded files.
      getChangelog: (_, __) async {
        // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/joodo/bunga_player/releases/latest",
        ));
        return jsonDecode(data.body)["body"];
      },
      closeOnInstall: true,
      launchOnExit: false,
      callback: (status) {
        logger.i('Update status: $status');
        if (status == UpdatStatus.available ||
            status == UpdatStatus.availableWithChangelog) {
          Future.microtask(() => getService<Toast>().show('检查到更新，正在下载…'));
        }
      },
      child: child,
    );
  }
}
