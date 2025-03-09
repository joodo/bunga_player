import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

typedef BCSGHPreset = ({
  String title,
  List<int> value,
});

class PlayEqPresetNotifier extends ValueNotifier<BCSGHPreset?> {
  static final presets = <BCSGHPreset>[
    (title: '默认', value: [0, 0, 0, 0, 0]),
    (title: '鲜艳与生动', value: [5, 20, 65, 10, 0]),
    (title: '电影感', value: [-5, 30, 10, -5, 0]),
    (title: '温暖与复古', value: [10, 15, 10, 5, 5]),
    (title: '凉爽与情绪化', value: [-5, 20, -10, -10, -5]),
    (title: '夜视模式', value: [30, 40, -30, 20, 90]),
    (title: '黑白经典', value: [0, 15, -100, 0, 0]),
    (title: '褐色调', value: [5, 10, -20, 0, 30]),
    (title: '高调', value: [20, -15, 10, 10, 0]),
    (title: '低调', value: [-20, 25, -10, -10, 0]),
    (title: '漂白偏移', value: [0, 30, -50, 0, 0]),
  ];
  PlayEqPresetNotifier() : super(presets.first);
}

final playerProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => PlayEqPresetNotifier()),
  ],
);
