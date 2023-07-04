import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class LoginControl extends StatefulWidget {
  final String? previousName;
  const LoginControl({super.key, this.previousName});

  @override
  State<LoginControl> createState() => _LoginControlState();
}

class _LoginControlState extends State<LoginControl> {
  static const _askNameText = '怎样称呼你？';

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Auto login
    Future.delayed(Duration.zero, () {
      final savedUserName = Preferences().get<String>('user_name');
      if (savedUserName != null) {
        _registerUser(savedUserName);
      } else {
        UINotifiers().hintText.value = _askNameText;
      }
    });

    if (widget.previousName != null) {
      _textController.text = widget.previousName!;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: ValueListenableBuilder(
            valueListenable: UINotifiers().isBusy,
            builder: (context, isBusy, child) => TextField(
              style: const TextStyle(height: 1.0),
              autofocus: true,
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              enabled: !isBusy,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _registerUser(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        MultiValueListenableBuilder(
          valueListenables: [
            _textController,
            UINotifiers().isBusy,
          ],
          builder: (context, values, child) {
            return FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: !values[1] && values[0].text.isNotEmpty
                  ? () => _registerUser(values[0].text)
                  : null,
              child: const Text('就这么定'),
            );
          },
        ),
      ],
    );
  }

  void _registerUser(String userName) async {
    UINotifiers().isBusy.value = true;
    UINotifiers().hintText.value = '正在连接母星……';

    try {
      await Chat().login(userName);
      Preferences().set('user_name', userName);
      _onLoginSuccess();
    } catch (e) {
      logger.e(e);
      showSnackBar('连接母星失败');
      UINotifiers().hintText.value = _askNameText;
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  void _onLoginSuccess() {
    Navigator.of(context).popAndPushNamed('control:welcome');
  }
}
