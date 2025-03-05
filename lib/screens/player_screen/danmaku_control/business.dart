import 'package:bunga_player/utils/business/preference_notifier.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class DanmakuBusiness extends SingleChildStatefulWidget {
  const DanmakuBusiness({super.key, super.child});

  @override
  State<DanmakuBusiness> createState() => _DanmakuBusinessState();
}

class _DanmakuBusinessState extends SingleChildState<DanmakuBusiness> {
  final _recentPopmojis = createPreferenceNotifier(
    key: 'recent_popmojis',
    initValue: ["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"],
  );

  @override
  void dispose() {
    _recentPopmojis.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _recentPopmojis),
      ],
      child: child,
    );
  }
}

extension WrapDanmakuBusiness on Widget {
  Widget wrapDanmakuBusiness({Key? key}) => DanmakuBusiness(
        key: key,
        child: this,
      );
}
