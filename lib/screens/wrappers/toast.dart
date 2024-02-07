import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';

class ToastWrapper extends StatefulWidget {
  const ToastWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<ToastWrapper> {
  late final _service = getService<Toast>();
  @override
  void initState() {
    _service.register(show);
    super.initState();
  }

  @override
  void dispose() {
    _service.unregister(show);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 76.0),
        content: Theme(
          data: ThemeData.light(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
