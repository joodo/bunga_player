import 'package:bunga_player/console/actions.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      SvgPicture.asset('assets/images/icons/icon.svg', width: 96)
          .padding(top: 24.0),
      const SizedBox(height: 16),
      Text(getIt<PackageInfo>().appName)
          .textStyle(Theme.of(context).textTheme.titleLarge!)
          .padding(top: 16.0),
      Text('版本: ${getIt<PackageInfo>().version}').padding(top: 8.0),
      TextButton(
        onPressed: () => showLicensePage(
          context: context,
          applicationName: getIt<PackageInfo>().appName,
        ),
        child: const Text('查看许可'),
      ).padding(top: 8.0),
      TextButton(
        onPressed: Actions.handler(context, ShowConsoleIntent()),
        child: const Text('控制台'),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center);
  }
}
