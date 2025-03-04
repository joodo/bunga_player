import 'dart:io';

import 'package:crclib/catalog.dart';

extension CRCString on File {
  Future<String> crcString() => openRead()
      .take(1000)
      .transform(Crc32Xz())
      .single
      .then((crcValue) => crcValue.toRadixString(36));
}
