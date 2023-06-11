import 'dart:async';
import 'dart:io';

import 'package:bunga_player/common/bili_video.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/logger.dart';
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

class BiliChannelInfo {
  final String id;
  final String name;
  final String pic;
  final String creator;
  final String bvid;
  final int p;

  BiliChannelInfo({
    required this.id,
    required this.name,
    required this.pic,
    required this.creator,
    required this.bvid,
    required this.p,
  });
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
                onOpenLinkPressed: _openBilibili,
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

      final success = await IMController().createOrJoinGroup(
        crcString,
        extraData: {
          'name': file.name,
          'video_type': 'local',
        },
      );
      if (success) {
        await VideoController().loadVideo(file.path);
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

  void _openBilibili() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const BiliDialog(),
    );

    String failedString = '';
    try {
      final BiliVideo biliVideo;
      if (result is String && result.isNotEmpty) {
        // Parse bilibili url
        setState(() {
          _uIState = UIState.loadVideoInProgress;
        });
        failedString = '解析失败';
        biliVideo = await BiliVideo.fromUrl(Uri.parse(result));
      } else if (result is BiliChannelInfo) {
        // Parse bvid and p
        setState(() {
          _uIState = UIState.loadVideoInProgress;
        });
        failedString = '加入失败';
        biliVideo = BiliVideo(bvid: result.bvid, p: result.p);
      } else {
        return;
      }

      await biliVideo.fetch();
      if (!biliVideo.isHD) {
        showSnackBar('无法获取高清视频');
        logger.w('Bilibili: Cookie of serverless funtion outdated');
      }

      await VideoController().loadVideo(biliVideo.videoUrls);
      await IMController().createOrJoinGroup(
        'bili_${biliVideo.cid}',
        extraData: {
          'video_type': 'bilibili',
          'name': biliVideo.title,
          'pic': biliVideo.pic,
          'bvid': biliVideo.bvid,
          'p': biliVideo.p,
        },
      );

      setState(() {
        windowManager.setTitle(biliVideo.title);
        _uIState = UIState.playVideo;
      });
    } catch (e) {
      logger.e(e);
      showSnackBar(failedString);
      setState(() {
        _uIState = UIState.greeting;
      });
    }
  }
}

class CatWidget extends StatelessWidget {
  final String hintText;
  final bool isCatWaken;
  // HACK: Dirty static
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
  final VoidCallback? onOpenLinkPressed;
  final VoidCallback? onLogoutPressed;

  const VideoOpenWidget({
    super.key,
    this.onOpenPressed,
    this.onLogoutPressed,
    this.onOpenLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onLogoutPressed,
          child: const Text('换个名字'),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: onOpenPressed,
          child: const Text('打开视频文件'),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: onOpenLinkPressed,
          child: const Text('Bilibili 视频'),
        ),
      ],
    );
  }
}

class BiliDialog extends StatefulWidget {
  const BiliDialog({super.key});

  @override
  State<BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<BiliDialog> {
  List<BiliChannelInfo> _channels = [];
  late final Timer _timer;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    _timer = _createUpdateTimer();
    super.initState();
  }

  @override
  dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              '加入其他人',
              style: themeData.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // HACK: cannot use listview because bug
            // https://github.com/flutter/flutter/issues/26527
            _channels.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Row(
                          children: _channels
                              .map((info) => _createVideoCard(info))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Text(
              '或打开新视频',
              style: themeData.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '视频链接',
              ),
              onTap: () {
                _textController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _textController.text.length,
                );
              },
              onSubmitted: (text) {
                if (text.isNotEmpty) _onSubmitBiliUrl();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('取消'),
        ),
        ValueListenableBuilder(
          valueListenable: _textController,
          builder: (context, value, child) => TextButton(
            onPressed: value.text.isEmpty ? null : _onSubmitBiliUrl,
            child: const Text('解析'),
          ),
        ),
      ],
    );
  }

  void _onSubmitBiliUrl() {
    Navigator.pop(context, _textController.text);
  }

  Widget _createVideoCard(BiliChannelInfo channelInfo) {
    final themeData = Theme.of(context);
    final videoImage = Image.network(
      channelInfo.pic,
      height: 125,
      width: 200,
      fit: BoxFit.cover,
    );

    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        videoImage,
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    channelInfo.creator,
                    style: themeData.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '分享',
                  style: themeData.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Tooltip(
              message: channelInfo.name,
              child: Text(
                channelInfo.name,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );

    final themedCard = FutureBuilder<ColorScheme>(
      future: ColorScheme.fromImageProvider(
        brightness: themeData.brightness,
        provider: videoImage.image,
      ),
      initialData: themeData.colorScheme,
      builder: (context, colorScheme) {
        final builder = Builder(
          builder: (context) {
            final themeData = Theme.of(context);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              clipBehavior: Clip.hardEdge,
              color: ElevationOverlay.applySurfaceTint(
                themeData.colorScheme.surfaceVariant,
                themeData.colorScheme.surfaceTint,
                0,
              ),
              elevation: 0,
              child: InkWell(
                onTap: () => Navigator.pop(context, channelInfo),
                child: cardContent,
              ),
            );
          },
        );
        return Theme(
          data: themeData.copyWith(
            colorScheme: colorScheme.data,
          ),
          child: builder,
        );
      },
    );

    return themedCard;
  }

  Timer _createUpdateTimer() {
    void updateChannel(_) async {
      final channels = await IMController().fetchChannels();

      if (!mounted) return;
      setState(() {
        _channels = channels
            .map((channel) => BiliChannelInfo(
                  id: channel.id!,
                  name: channel.name!,
                  pic: channel.extraData['pic'] as String,
                  creator: channel.createdBy!.name,
                  bvid: channel.extraData['bvid'] as String,
                  p: channel.extraData['p'] as int,
                ))
            .toList();
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
