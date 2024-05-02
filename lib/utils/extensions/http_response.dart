import 'package:http/http.dart';

extension CheckStatus on BaseResponse {
  bool get isSuccess => statusCode ~/ 100 == 2;
}
