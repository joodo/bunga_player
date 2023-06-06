import 'dart:io';

import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/player_widget.dart';
import 'package:crclib/catalog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:rive/rive.dart';

enum UIState {
  register,
  registerInProgress,
  greeting,
  loadVideoInProgress,
  playVideo,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _uIState = UIState.register;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();

    // Auto login
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      final String? userName = _prefs!.getString('user_name');
      if (userName != null) {
        Future.delayed(
          Duration.zero,
          () => _registerUser(userName),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_uIState) {
      case UIState.register:
        return Column(
          children: [
            const Expanded(
              child: CatWidget(
                isCatWaken: false,
                hintText: '如何称呼你？',
              ),
            ),
            SizedBox(
              height: 64,
              child: UserNameInputWidget(
                onUserNameSubmited: _registerUser,
              ),
            ),
          ],
        );
      case UIState.registerInProgress:
        return const Column(
          children: [
            Expanded(
              child: CatWidget(
                isCatWaken: false,
                hintText: '正在连接到母星…',
              ),
            ),
            SizedBox(
              height: 64,
              child: UserNameInputWidget(),
            ),
          ],
        );
      case UIState.greeting:
        final userName = _prefs!.getString('user_name');
        return Column(
          children: [
            Expanded(
              child: CatWidget(
                isCatWaken: true,
                hintText: '$userName，你好',
              ),
            ),
            SizedBox(
              height: 64,
              child: VideoOpenWidget(
                onOpenPressed: _openVideo,
                onLogoutPressed: _logout,
              ),
            ),
          ],
        );
      case UIState.loadVideoInProgress:
        return const Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Expanded(
                  child: CatWidget(
                    isCatWaken: true,
                    hintText: '正在收拾客厅…',
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: VideoOpenWidget(),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
          ],
        );
      case UIState.playVideo:
        return const PlayerWidget();
    }
  }

  void _registerUser(String userName) async {
    setState(() {
      _uIState = UIState.registerInProgress;
    });

    bool success = await IMController().login(userName);
    if (!success) {
      showSnackBar('连接母星失败');
      setState(() {
        _uIState = UIState.register;
      });
      return;
    }

    success = await _prefs!.setString('user_name', userName);
    if (!success) {
      showSnackBar('没记住你的名字……');
    }

    setState(() {
      _uIState = UIState.greeting;
    });
  }

  void _logout() async {
    await IMController().logout();

    await _prefs!.remove('user_name');

    setState(() {
      _uIState = UIState.register;
    });
  }

  void _openVideo() async {
    const typeGroup = XTypeGroup(
      label: 'videos',
      extensions: <String>[
        'webm',
        'mkv',
        'flv',
        'vob',
        'ogv',
        'ogg',
        'rrc',
        'gifv',
        'mpeg',
        'rm',
        'qt',
        'mng',
        'mov',
        'avi',
        'wmv',
        'yuv',
        'asf',
        'amv',
        'mp4',
        'm4p',
        'm4v',
        'mpg',
        'mp2',
        'mpe',
        'mpv',
        'm4v',
        'svi',
        '3gp',
        '3g2',
        'mxf',
        'roq',
        'nsv',
        'flv',
        'f4v',
        'f4p',
        'f4a',
        'f4b',
        'mod',
      ],
    );
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      setState(() {
        _uIState = UIState.loadVideoInProgress;
      });

      final crcValue = await File(file.path)
          .openRead()
          .take(1000)
          .transform(Crc32Xz())
          .single;
      final crcString = crcValue.toString();

      final success =
          await IMController().createOrJoinGroup(crcString, file.name);
      if (success) {
        // Open video
        VideoController().source.value = file.path;

        setState(() {
          windowManager.setTitle(file.name);
          _uIState = UIState.playVideo;
        });
      } else {
        setState(() {
          _uIState = UIState.greeting;
        });
      }
    }
  }
}

class CatWidget extends StatelessWidget {
  final String hintText;
  final bool isCatWaken;
  // FIXME: Dirty static
  static SMIBool? _isCatAwakeInput;

  const CatWidget({
    super.key,
    this.hintText = '',
    this.isCatWaken = false,
  });

  @override
  Widget build(BuildContext context) {
    _isCatAwakeInput?.value = isCatWaken;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 400,
          child: RiveAnimation.asset(
            'assets/images/wake_up_the_black_cat.riv',
            onInit: (Artboard artboard) {
              final controller = StateMachineController.fromArtboard(
                  artboard, 'State Machine 1');
              artboard.addController(controller!);

              _isCatAwakeInput =
                  controller.findInput<bool>('isWaken') as SMIBool;
              _isCatAwakeInput!.value = isCatWaken;
            },
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 320,
            ),
            Text(
              hintText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );
  }
}

class UserNameInputWidget extends StatelessWidget {
  final ValueSetter<String>? onUserNameSubmited;

  const UserNameInputWidget({
    super.key,
    this.onUserNameSubmited,
  });

  @override
  Widget build(BuildContext context) {
    var userNameController = TextEditingController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: TextField(
            style: const TextStyle(height: 1.0),
            autofocus: true,
            controller: userNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            enabled: onUserNameSubmited != null,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                onUserNameSubmited?.call(value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: userNameController,
          builder: (context, value, child) {
            return FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: onUserNameSubmited != null && value.text.isNotEmpty
                  ? () {
                      onUserNameSubmited!.call(userNameController.text);
                    }
                  : null,
              child: onUserNameSubmited != null
                  ? const Text('就这么定')
                  : const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}

class VideoOpenWidget extends StatelessWidget {
  final VoidCallback? onOpenPressed;
  final VoidCallback? onLogoutPressed;

  const VideoOpenWidget({
    super.key,
    this.onOpenPressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: onOpenPressed,
          child: const Text('打开视频'),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: onLogoutPressed,
          child: const Text('换个名字'),
        ),
      ],
    );
  }
}
