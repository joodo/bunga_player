import 'package:bunga_player/common/video_open.dart';
import 'package:bunga_player/singletons/chat.dart';
import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  String get _welcomeText => '${Chat().currentUserNotifier.value?.name}, 你好！';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      UINotifiers().hintText.value = _welcomeText;
      windowManager.setTitle('Bunga Player');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isBusy,
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy ? null : _logout,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _openLocalVideo,
            child: const Text('打开视频文件'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _openBilibili,
            child: const Text('Bilibili 视频'),
          ),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    UINotifiers().isBusy.value = true;
    try {
      final data = await openLocalVideo();

      UINotifiers().hintText.value = '正在发送请柬……';
      await Chat().createOrJoinRoomByHash(
        data.hash,
        extraData: {
          'name': data.name,
          'hash': data.hash,
          'video_type': 'local',
        },
      );
      IMVideoConnector().askPosition();

      UINotifiers().hintText.value = null;
      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('加载失败');
      }
      UINotifiers().hintText.value = _welcomeText;
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  void _openBilibili() async {
    UINotifiers().isBusy.value = true;
    try {
      final biliChannel = await openBiliVideo(context);

      UINotifiers().hintText.value = '正在发送请柬……';
      if (biliChannel.id == null) {
        await Chat().createOrJoinRoomByHash(
          biliChannel.hash,
          extraData: {
            'video_type': 'bilibili',
            'hash': biliChannel.hash,
            'name': biliChannel.name,
            'pic': biliChannel.pic,
          },
        );
      } else {
        await Chat().joinRoomById(biliChannel.id!);
      }
      IMVideoConnector().askPosition();

      UINotifiers().hintText.value = null;
      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('解析失败');
      }
      UINotifiers().hintText.value = _welcomeText;
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  void _logout() async {
    await Chat().logout();
    SharedPreferences.getInstance().then((pref) => pref.remove('user_name'));
    _onLoggedOut();
  }

  void _onLoggedOut() {
    Navigator.of(context).popAndPushNamed('control:login');
  }

  void _onVideoLoaded() {
    Navigator.of(context).popAndPushNamed('control:main');
  }
}
