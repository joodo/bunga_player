import 'dart:io';

import 'package:bunga_player/common/im.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget.dart';
import 'package:crclib/catalog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:rive/rive.dart';

enum UIState {
  register,
  registerInProgress,
  greeting,
  loadVideoInProgress,
  playVideo,
  unknown,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _uIState = UIState.register;

  SharedPreferences? _prefs;

  String? _videoPath;
  String? _groupID;

  bool _showLog = false;

  @override
  void initState() {
    super.initState();

    // Window
    windowManager.setTitle('Bunga Player');
    windowManager.setMinimumSize(const Size(800, 600));

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
    final Widget body;
    switch (_uIState) {
      case UIState.register:
        body = Column(
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
        break;
      case UIState.registerInProgress:
        body = const Column(
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
        break;
      case UIState.greeting:
        final userName = _prefs!.getString('user_name');
        body = Column(
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
        break;
      case UIState.loadVideoInProgress:
        body = const Stack(
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
        break;
      case UIState.playVideo:
        body = Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: PlayerWidget(
            videoPath: _videoPath!,
            groupID: _groupID!,
          ),
        );
        break;
      case UIState.unknown:
        return Center(
          child: Text(
            '出问题了……',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        body,
        CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.f12): () {
              setState(() {
                _showLog = !_showLog;
              });
            },
          },
          child: Focus(
            autofocus: true,
            child: Visibility(
              maintainState: true,
              visible: _showLog,
              child: const LogView(),
            ),
          ),
        ),
      ],
    );
  }

  void _registerUser(String userName) async {
    setState(() {
      _uIState = UIState.registerInProgress;
    });

    final iM = Provider.of<IM>(context, listen: false);

    bool success = await iM.login(userName);
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
    final iM = Provider.of<IM>(context, listen: false);
    await iM.logout();

    await _prefs!.remove('user_name');

    setState(() {
      _uIState = UIState.register;
    });
  }

  void _openVideo() async {
    final iM = Provider.of<IM>(context, listen: false);

    const typeGroup = XTypeGroup(
      label: 'videos',
      extensions: <String>['mp4', 'mkv', 'avi', 'rmvb', 'mpg', 'mpeg'],
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

      final success = await iM.createOrJoinGroup(crcString, file.name);
      if (success) {
        // Open video
        final controller = VideoController.instance();
        await controller.setDataSource(
          DataSource(
            type: DataSourceType.file,
            file: File(file.path),
          ),
          autoplay: false,
        );
        controller.onVideoFitChange(BoxFit.contain);

        setState(() {
          windowManager.setTitle(file.name);
          _videoPath = file.path;
          _groupID = crcString;
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
            'images/wake_up_the_black_cat.riv',
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
          child: const Text('别这么叫我'),
        ),
      ],
    );
  }
}
