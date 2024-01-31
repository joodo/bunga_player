import 'package:flutter/material.dart';

extension ShowToast on BuildContext {
  void showToast(String text) {
    findAncestorStateOfType<_ToastWrapperState>()!.show(text);
  }
}

class ToastWrapper extends StatefulWidget {
  const ToastWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<ToastWrapper> {
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
