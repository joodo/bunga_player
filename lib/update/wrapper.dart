import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bunga_player/update/global_business.dart';
import 'package:bunga_player/update/models/update_info.dart';

import 'utils.dart';

class ShowUpdateDetailIntent extends Intent {
  const ShowUpdateDetailIntent();
}

class UpdateWrapper extends SingleChildStatelessWidget {
  const UpdateWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);
    if (disabledUpdateCheck) return child!;

    final wrapper = Consumer<UpdateStatus>(
      builder: (context, status, _) => [
        child!,
        Visibility(
          visible:
              status == UpdateStatus.downloading ||
              status == UpdateStatus.readyToInstall,
          child:
              [
                    ListTile(
                      leading: SizedBox.square(
                        dimension: 24,
                        child: status == UpdateStatus.readyToInstall
                            ? const Icon(Icons.install_desktop)
                            : Consumer<UpdateDownloadProgress?>(
                                builder: (context, progress, child) =>
                                    CircularProgressIndicator(
                                      value: progress?.percent ?? 0.0,
                                    ),
                              ),
                      ),
                      titleAlignment: ListTileTitleAlignment.center,
                      title: const Text('新更新可用'),
                      subtitle: status == UpdateStatus.downloading
                          ? const Text('正在下载……')
                          : Text(
                              '已准备好安装 ${context.read<UpdateInfo?>()?.version} 。',
                            ),
                    ),
                    [
                      TextButton(
                        onPressed: () => _showUpdateDetail(context),
                        child: const Text('详情'),
                      ),
                      if (status == UpdateStatus.readyToInstall)
                        TextButton(
                          onPressed: Actions.handler(
                            context,
                            InstallUpdateIntent(),
                          ),
                          child: const Text('现在安装'),
                        ),
                    ].toRow(mainAxisAlignment: MainAxisAlignment.end),
                  ]
                  .toColumn(mainAxisSize: MainAxisSize.min)
                  .padding(bottom: 8.0, right: 8.0)
                  .card(elevation: 8.0)
                  .positioned(bottom: 72.0, right: 8.0, width: 270.0),
        ),
      ].toStack(fit: StackFit.expand),
    );

    final actions = Actions(
      actions: {
        ShowUpdateDetailIntent: CallbackAction<ShowUpdateDetailIntent>(
          onInvoke: (intent) => _showUpdateDetail(context),
        ),
      },
      child: wrapper,
    );

    return actions;
  }

  void _showUpdateDetail(BuildContext context) {
    final info = context.read<UpdateInfo>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(info.name),
        content:
            Markdown(
                  data: info.body,
                  shrinkWrap: true,
                  selectable: true,
                  onTapLink: (text, href, title) => launchUrl(Uri.parse(href!)),
                )
                .backgroundColor(Theme.of(context).colorScheme.surfaceContainer)
                .constrained(width: 400.0),
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 18.0),
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
