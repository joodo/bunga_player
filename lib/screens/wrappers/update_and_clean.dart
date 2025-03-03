import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nested/nested.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

enum UpdateStatus {
  checking,
  updated,
  downloading,
  readyToInstall,
  error,
}

class UpdateAndCleanWrapper extends SingleChildStatefulWidget {
  const UpdateAndCleanWrapper({super.key, super.child});

  @override
  State<UpdateAndCleanWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends SingleChildState<UpdateAndCleanWrapper> {
  UpdateStatus _status = UpdateStatus.checking;
  RequestProgress? _downloadProgress;
  String _latestVersion = '';
  late ({String title, String body}) _updateDetail;
  late String _installFilePath;

  @override
  void initState() {
    super.initState();

    _checkUpdate().onError((error, stackTrace) {
      logger.e('Update: error: $error');
      if (mounted) {
        setState(() {
          _status = UpdateStatus.error;
        });
      }
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (Platform.isIOS) return child!;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (child != null) child,
        Visibility(
          visible: _status == UpdateStatus.downloading ||
              _status == UpdateStatus.readyToInstall,
          child: Positioned(
            bottom: 72,
            right: 8,
            child: SizedBox(
              width: 270,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: SizedBox.square(
                          dimension: 24,
                          child: _status == UpdateStatus.readyToInstall
                              ? const Icon(Icons.install_desktop)
                              : CircularProgressIndicator(
                                  value: _downloadProgress?.percent,
                                ),
                        ),
                        titleAlignment: ListTileTitleAlignment.center,
                        title: const Text('新更新可用'),
                        subtitle: _status == UpdateStatus.downloading
                            ? const Text('正在下载……')
                            : Text('已准备好安装 $_latestVersion 。'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _showUpdateDetail,
                            child: const Text('详情'),
                          ),
                          if (_status == UpdateStatus.readyToInstall)
                            TextButton(
                              onPressed: _install,
                              child: const Text('现在安装'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkUpdate() async {
    if (Platform.isIOS) return;

    final response = await http.get(Uri.parse(
      'https://gitee.com/api/v5/repos/joodo2/bunga_player/releases/latest',
    ));
    final responseData = jsonDecode(utf8.decode(response.body.runes.toList()));

    _latestVersion = responseData['tag_name'] as String;
    final currentVersion = getIt<PackageInfo>().version;
    logger
        .i('Current version: $currentVersion, Latest version: $_latestVersion');
    if (Version.parse(_latestVersion) <= Version.parse(currentVersion)) {
      setState(() {
        _status = UpdateStatus.updated;
      });
      _cleanTempDir();
      return;
    }

    _updateDetail = (
      title: responseData['name'],
      body: responseData['body'],
    );

    final fileName = _updateFileName();
    final tempDir = await getApplicationCacheDirectory();
    _installFilePath = '${tempDir.path}/$fileName';

    if (!await File(_installFilePath).exists()) {
      setState(() {
        _status = UpdateStatus.downloading;
      });
      final binaryUrl = (responseData['assets'] as List)
          .firstWhere((e) => e['name'] == fileName)['browser_download_url'];
      await for (final progress in getIt<NetworkService>()
          .downloadFile(binaryUrl, _installFilePath)) {
        setState(() {
          _downloadProgress = progress;
        });
      }
    }
    setState(() {
      _downloadProgress = null;
      _status = UpdateStatus.readyToInstall;
    });
  }

  Future<void> _install() async {
    await getIt<Permissions>().requestInstallPackage();

    await OpenFile.open(_installFilePath);

    if (kIsDesktop) {
      await ServicesBinding.instance.exitApplication(AppExitType.cancelable);
    }
  }

  String _updateFileName() {
    const prefix = 'bunga_player_';

    final suffix = switch (Platform.operatingSystem) {
      'windows' => '.exe',
      'macos' => '.dmg',
      'android' => '_arm64-v8a.apk',
      String() =>
        throw Exception('Update: unknown platform ${Platform.operatingSystem}'),
    };

    final version = 'v$_latestVersion';

    return '$prefix$version$suffix';
  }

  void _showUpdateDetail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_updateDetail.title),
        content: SizedBox(
          width: 400,
          child: Markdown(
            data: _updateDetail.body,
            shrinkWrap: true,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _cleanTempDir() async {
    final tempDir = await getApplicationCacheDirectory();
    await for (final entry in tempDir.list().where((entry) => entry is File)) {
      logger.i('Update: clean temp file ${entry.path}');
      try {
        await entry.delete();
      } catch (e) {
        logger.i(e);
      }
    }
  }
}
