import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:version/version.dart';

import 'models/update_info.dart';
import 'utils.dart';

enum UpdateStatus {
  disabled,
  checking,
  updated,
  downloading,
  readyToInstall,
  error,
}

class UpdateLastCheckedNotifier extends ValueNotifier<UpdateInfo?> {
  UpdateLastCheckedNotifier() : super(null) {
    bindPreference<String>(
      key: 'update_last_checked',
      load: (pref) => UpdateInfo.fromJson(jsonDecode(pref)),
      update: (value) => value != null ? jsonEncode(value.toJson()) : null,
    );
  }
}

class UpdateDownloadProgress extends RequestProgress {
  const UpdateDownloadProgress({required super.total, required super.current});
}

class CheckUpdateIntent extends Intent {
  const CheckUpdateIntent();
}

class InstallUpdateIntent extends Intent {
  const InstallUpdateIntent();
}

class UpdateGlobalBusiness extends SingleChildStatefulWidget {
  const UpdateGlobalBusiness({super.key, super.child});

  @override
  State<UpdateGlobalBusiness> createState() => _UpdateGlobalBusinessState();
}

class _UpdateGlobalBusinessState
    extends SingleChildState<UpdateGlobalBusiness> {
  static const _latestUrl =
      'https://gitee.com/api/v5/repos/joodo2/bunga_player/releases/latest';

  final _updateStatusNotifier =
      ValueNotifier<UpdateStatus>(UpdateStatus.updated);
  final _updateLastCheckedNotifier = UpdateLastCheckedNotifier();
  final _updateDownloadProgressNotifier =
      ValueNotifier<UpdateDownloadProgress?>(null);

  late String _installFilePath;

  @override
  void initState() {
    super.initState();

    if (disabledUpdateCheck) {
      _updateStatusNotifier.value = UpdateStatus.disabled;
      return;
    }

    if (_updateLastCheckedNotifier.value != null &&
        DateTime.now()
                .difference(_updateLastCheckedNotifier.value!.checkedAt)
                .inHours <
            24) {
      return;
    }

    _checkUpdate().onError(
      (error, stackTrace) {
        getIt<Toast>().show('检查更新失败，请稍后再试。');
        logger.e('Update: error: $error');
        return false;
      },
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final actions = Actions(
      actions: {
        CheckUpdateIntent: CallbackAction<CheckUpdateIntent>(
          onInvoke: (intent) => _checkUpdate(),
        ),
        InstallUpdateIntent: CallbackAction<InstallUpdateIntent>(
          onInvoke: (intent) => _installUpdate(),
        ),
      },
      child: child!,
    );
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _updateStatusNotifier),
        ValueListenableProvider.value(value: _updateLastCheckedNotifier),
        ValueListenableProvider.value(value: _updateDownloadProgressNotifier),
      ],
      child: actions,
    );
  }

  @override
  void dispose() {
    _updateStatusNotifier.dispose();
    _updateLastCheckedNotifier.dispose();
    _updateDownloadProgressNotifier.dispose();
    super.dispose();
  }

  Future<bool> _checkUpdate() async {
    assert(_updateStatusNotifier.value == UpdateStatus.updated ||
        _updateStatusNotifier.value == UpdateStatus.error);

    final response = await http.get(Uri.parse(_latestUrl));
    final responseData = jsonDecode(utf8.decode(response.body.runes.toList()));

    final latestVersion = responseData['tag_name'] as String;
    final latestName = responseData['name'];
    final latestBody = responseData['body'];
    final installerFileName = _installerFileName(latestVersion);
    final downloadUrl = (responseData['assets'] as List).firstWhere(
        (e) => e['name'] == installerFileName)['browser_download_url'];
    _updateLastCheckedNotifier.value = UpdateInfo(
      checkedAt: DateTime.now(),
      version: latestVersion,
      name: latestName,
      body: latestBody,
      downloadUrl: downloadUrl,
    );

    final currentVersion = getIt<PackageInfo>().version;
    logger
        .i('Current version: $currentVersion, Latest version: $latestVersion');
    if (Version.parse(latestVersion) <= Version.parse(currentVersion)) {
      _updateStatusNotifier.value = UpdateStatus.updated;
      return false;
    }

    final tempDir = await getApplicationCacheDirectory();
    _installFilePath = '${tempDir.path}/$installerFileName';

    if (!await File(_installFilePath).exists()) {
      _updateStatusNotifier.value = UpdateStatus.downloading;

      await for (final progress in getIt<NetworkService>()
          .downloadFile(downloadUrl, _installFilePath)) {
        _updateDownloadProgressNotifier.value = UpdateDownloadProgress(
          total: progress.total,
          current: progress.current,
        );
      }
    }
    _updateDownloadProgressNotifier.value = null;
    _updateStatusNotifier.value = UpdateStatus.readyToInstall;
    return true;
  }

  Future<void> _installUpdate() async {
    await getIt<Permissions>().requestInstallPackage();

    await OpenFile.open(_installFilePath);

    if (kIsDesktop) {
      await ServicesBinding.instance.exitApplication(AppExitType.cancelable);
    }
  }

  String _installerFileName(String version) {
    const prefix = 'bunga_player_';

    final suffix = switch (Platform.operatingSystem) {
      'windows' => '.exe',
      'macos' => '.dmg',
      'android' => '_arm64-v8a.apk',
      String() =>
        throw Exception('Update: unknown platform ${Platform.operatingSystem}'),
    };

    return '${prefix}v$version$suffix';
  }
}
