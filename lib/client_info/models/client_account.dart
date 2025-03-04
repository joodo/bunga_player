import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_account.freezed.dart';
part 'client_account.g.dart';

@freezed
abstract class ClientAccount with _$ClientAccount {
  const factory ClientAccount({
    @JsonKey(name: "username") required String id,
    required String password,
  }) = _ClientAccount;

  factory ClientAccount.fromJson(Map<String, dynamic> json) =>
      _$ClientAccountFromJson(json);
}
