import 'package:bunga_player/utils/extensions/string.dart';

extension AListPathToId on String {
  String asPathToAListId() => 'alist-$hashStr';
}
