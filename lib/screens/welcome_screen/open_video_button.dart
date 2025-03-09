import 'package:animations/animations.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class OpenVideoButton extends StatelessWidget {
  final void Function(OpenVideoDialogResult?)? onFinished;
  const OpenVideoButton({super.key, this.onFinished});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer<OpenVideoDialogResult?>(
      closedBuilder: (context, openContainer) => FilledButton(
        onPressed: openContainer,
        child: const Text('我来放'),
      ).constrained(width: 100.0),
      closedColor: theme.primaryColor,
      openBuilder: (dialogContext, closeContainer) => const Dialog.fullscreen(
        child: OpenVideoDialog(),
      ),
      openColor: theme.primaryColor,
      onClosed: (data) {
        onFinished?.call(data);
      },
    );
  }
}
