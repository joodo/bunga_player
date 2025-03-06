import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class CallingSettingsPanel extends StatelessWidget implements Panel {
  const CallingSettingsPanel({super.key});

  @override
  final type = 'video_source';

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      title: '语音设置',
      child: [
        const Text('设备')
            .textStyle(Theme.of(context).textTheme.labelMedium!)
            .padding(horizontal: 16.0, top: 8.0, bottom: 8.0),
        ...['设备1', '设备2', '设备3'].map((e) => RadioListTile(
              title: Text(e),
              value: e,
              groupValue: '设备1',
              onChanged: (value) {},
            )),
        const Text('降噪')
            .textStyle(Theme.of(context).textTheme.labelMedium!)
            .padding(horizontal: 16.0, top: 24.0, bottom: 8.0),
        ...['关', '低', '中', '高'].map((e) => RadioListTile(
              title: Text(e),
              value: e,
              groupValue: '高',
              onChanged: (value) {},
            )),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .scrollable(padding: EdgeInsets.only(bottom: 16.0)),
    );
  }
}
