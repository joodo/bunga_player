import 'package:bunga_player/utils/extensions/duration.dart';

extension RelativeTime on DateTime {
  String get relativeString {
    final sec = DateTime.now().difference(this);

    if (sec.isNegative) return '将来';

    if (sec.inYears > 0) return '${sec.inYears} 年前';
    if (sec.inMonths > 0) return '${sec.inMonths} 月前';
    if (sec.inDays > 0) return '${sec.inDays} 天前';
    if (sec.inHours > 0) return '${sec.inHours} 小时前';
    if (sec.inMinutes > 3) return '${sec.inMinutes} 分钟前';
    return '刚刚';
  }
}
