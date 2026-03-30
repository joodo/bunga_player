import '/utils/utils.dart';

extension AListPathToId on String {
  String asPathToAListId() => 'alist-$hashStr';
}
