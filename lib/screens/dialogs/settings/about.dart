import 'package:bunga_player/console/wrapper.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/update/global_business.dart';
import 'package:bunga_player/update/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class AboutSetting extends StatelessWidget with SettingsTab {
  @override
  final label = '关于';
  @override
  final icon = Icons.info_outline;
  @override
  final selectedIcon = Icons.info;

  const AboutSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      SvgPicture.asset('assets/images/icon.svg', width: 96).padding(top: 24.0),
      Text('Bunga Player')
          .textStyle(Theme.of(context).textTheme.titleLarge!)
          .padding(vertical: 8.0),
      Text('版本: ${getIt<PackageInfo>().version}'),
      Selector<UpdateStatus, bool>(
        selector: (context, status) =>
            status == UpdateStatus.updated || status == UpdateStatus.error,
        builder: (context, enabled, child) => [
          TextButton(
            onPressed: enabled ? () => _forceCheckUpdate(context) : null,
            child: const Text('检查更新'),
          ),
          TextButton(
            onPressed: enabled
                ? Actions.handler(context, ShowUpdateDetailIntent())
                : null,
            child: const Text('更新日志'),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ),
      const SizedBox(height: 16.0),
      [
        FilledButton(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: getIt<PackageInfo>().appName,
          ),
          child: const Text('查看许可'),
        ),
        FilledButton(
          onPressed: Actions.handler(context, ToggleConsoleIntent()),
          child: const Text('控制台'),
        ),
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.center,
        separator: const SizedBox(width: 12.0),
      ),
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.center,
      separator: const SizedBox(height: 8.0),
    );
  }

  void _forceCheckUpdate(BuildContext context) async {
    final job = Actions.invoke(context, CheckUpdateIntent()) as Future<bool>;
    final hasNewUpdate = await job;
    if (!hasNewUpdate) {
      getIt<Toast>().show('已是最新版本');
    }
  }
}
