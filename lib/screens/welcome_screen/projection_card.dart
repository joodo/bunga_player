import 'dart:typed_data';

import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:styled_widget/styled_widget.dart';

class ProjectionCard extends StatefulWidget {
  final StartProjectionMessageData data;
  final VoidCallback? onTap;

  const ProjectionCard({super.key, required this.data, this.onTap});

  @override
  State<ProjectionCard> createState() => _ProjectionCardState();
}

class _ProjectionCardState extends State<ProjectionCard> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _getNetworkImageData(widget.data.videoRecord.thumbUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final videoImage = _imageData != null
        ? Ink.image(
            image: MemoryImage(_imageData!),
            fit: BoxFit.cover,
            width: 300,
            height: 200,
          )
        : const SizedBox(
            width: 300,
            height: 200,
            child: Center(child: Icon(Icons.smart_display, size: 180)),
          );

    final textTheme = Theme.of(context).textTheme;
    final content = InkWell(
      onTap: widget.onTap,
      child:
          [
                videoImage,
                Text(
                      widget.data.videoRecord.title,
                      maxLines: 2,
                        overflow: .ellipsis,
                    )
                    .textStyle(textTheme.bodyLarge!)
                    .padding(horizontal: 16.0, top: 8.0),
                Text('${widget.data.sharer.name} 正在分享')
                    .textStyle(textTheme.bodySmall!)
                    .padding(horizontal: 16.0, top: 4.0, bottom: 16.0),
              ]
              .toColumn(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
              )
              .constrained(width: 300),
    );

    final card = Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return content.card(
          color: colorScheme.primaryContainer,
          clipBehavior: Clip.hardEdge,
        );
      },
    );

    final themeData = Theme.of(context);
    try {
      return FutureBuilder(
        future: ColorScheme.fromImageProvider(
          provider: MemoryImage(_imageData!),
          brightness: Brightness.dark,
        ),
        initialData: themeData.colorScheme,
        builder: (context, snapshot) => Theme(
          data: themeData.copyWith(colorScheme: snapshot.data),
          child: card,
        ),
      ).fittedBox().center();
    } catch (e) {
      return card.fittedBox().center();
    }
  }

  void _getNetworkImageData(String uriString) async {
    try {
      final uri = Uri.parse(uriString);

      final response = await http.get(uri);
      if (!response.isSuccess) {
        throw Exception('image fetch failed: ${response.statusCode}');
      }
      _imageData = response.bodyBytes;

      if (mounted) setState(() {});
    } catch (e) {
      logger.w(e);
    }
  }
}
