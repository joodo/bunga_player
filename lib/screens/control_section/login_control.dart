import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginControl extends StatefulWidget {
  const LoginControl({super.key});

  @override
  State<LoginControl> createState() => _LoginControlState();
}

class _LoginControlState extends State<LoginControl> {
  static const _askNameText = '怎样称呼你？';

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((pref) {
      final userName = pref.get('user_name') as String?;
      if (userName != null) {
        // auto login
        _registerUser(userName);
      } else {
        UINotifiers().hintText.value = _askNameText;
      }
    });
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
      await IMController().login(userName);
      SharedPreferences.getInstance()
          .then((pref) => pref.setString('user_name', userName));
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
