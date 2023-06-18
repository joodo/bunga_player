import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/screens/control_section/indexed_stack_item.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

const askNameText = '怎样称呼你？';

class LoginControl extends StatefulWidget with IndexedStackItem {
  final ValueNotifier<bool> isBusyNotifier;
  final ValueNotifier<String?> hintTextNotifier;
  final VoidCallback? onLoginSuccess;

  const LoginControl({
    super.key,
    required this.isBusyNotifier,
    required this.hintTextNotifier,
    this.onLoginSuccess,
  });

  @override
  State<LoginControl> createState() => _LoginControlState();

  @override
  void onEnter() {
    hintTextNotifier.value = askNameText;
  }

  @override
  void onLeave() {
    hintTextNotifier.value = null;
  }
}

class _LoginControlState extends State<LoginControl> {
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
        // onEnter not trigger on init
        widget.hintTextNotifier.value = askNameText;
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
            valueListenable: widget.isBusyNotifier,
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
            widget.isBusyNotifier,
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
    widget.isBusyNotifier.value = true;
    widget.hintTextNotifier.value = '正在连接母星……';

    try {
      await IMController().login(userName);

      SharedPreferences.getInstance()
          .then((pref) => pref.setString('user_name', userName));

      widget.onLoginSuccess?.call();
    } catch (e) {
      logger.e(e);
      showSnackBar('连接母星失败');
      widget.hintTextNotifier.value = askNameText;
    } finally {
      widget.isBusyNotifier.value = false;
    }
  }
}
