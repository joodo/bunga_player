import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/painting.dart';

final Uint8List transparentImage = base64Decode(
  'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
);

final transparentImageProvider = MemoryImage(transparentImage);
