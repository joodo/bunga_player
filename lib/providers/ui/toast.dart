import 'package:flutter/material.dart';

class Toast {
  Toast(BuildContext context) : _context = context;
  final BuildContext _context;

  void show(String text) {
    ScaffoldMessenger.of(_context).showSnackBar(
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
