import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/network.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/network_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nested/nested.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

enum UpdateStatus {
  checking,
  updated,
  downloading,
  readyToInstall,
  error,
}

class UpdateWrapper extends SingleChildStatefulWidget {
  const UpdateWrapper({super.key, super.child});

  @override
  State<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends SingleChildState<UpdateWrapper> {
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
      setState(() {
        _status = UpdateStatus.error;
      });
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
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
    final response = await http.get(Uri.parse(
      "https://api.github.com/repos/joodo/bunga_player/releases/latest",
    ));
    final responseData = jsonDecode(response.body);

    _latestVersion = responseData['tag_name'] as String;
    final currentVersion = getIt<PackageInfo>().version;
    logger
        .i('Current version: $currentVersion, Latest version: $_latestVersion');
    if (_latestVersion.compareTo(currentVersion) <= 0) {
      setState(() {
        _status = UpdateStatus.updated;
      });
      return;
    }

    _updateDetail = (
      title: responseData['name'],
      body: responseData['body'],
    );

    final ext = switch (Platform.operatingSystem) {
      'windows' => 'exe',
      'macos' => 'dmg',
      String() =>
        throw Exception('Update: unknown platform ${Platform.operatingSystem}'),
    };
    final fileName =
        'bunga_player_installer_${_latestVersion.replaceAll('.', '_')}_${Platform.operatingSystem}.$ext';
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

  Future<void> _openPath(String path) async {
    if (Platform.isWindows) {
      await Process.start(path, []);
    } else if (Platform.isMacOS) {
      await Process.start('open', [path]);
    }
  }

  Future<void> _install() async {
    await _openPath(_installFilePath);
    await ServicesBinding.instance.exitApplication(AppExitType.cancelable);
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
}
