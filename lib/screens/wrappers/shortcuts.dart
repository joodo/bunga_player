import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class ShortcutsWrapper extends SingleChildStatelessWidget {
  const ShortcutsWrapper({super.key, super.child});

  static const _intentMapping = <ShortcutKey, Intent>{
    ShortcutKey.volumeUp: SetVolumeIntent.increase(10),
    ShortcutKey.volumeDown: SetVolumeIntent.increase(-10),
    ShortcutKey.forward5Sec: SeekIntent.increase(Duration(seconds: 5)),
    ShortcutKey.backward5Sec: SeekIntent.increase(Duration(seconds: -5)),
    ShortcutKey.togglePlay: TogglePlayIntent(),
    ShortcutKey.screenshot: ScreenshotIntent(),
  };

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<SettingShortcutMapping>(
      builder: (context, shortcutMapping, child) => Shortcuts(
        shortcuts: (shortcutMapping.value.map<SingleActivator?, ShortcutKey>(
                (key, value) => MapEntry(value, key))
              ..remove(null))
            .map<SingleActivator, Intent>(
                (key, value) => MapEntry(key!, _intentMapping[value]!)),
        child: child!,
      ),
      child: child,
    );
  }
}
