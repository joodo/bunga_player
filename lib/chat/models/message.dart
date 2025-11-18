import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required Map<String, dynamic> data,
    required String senderId,
  }) = _Message;
}
