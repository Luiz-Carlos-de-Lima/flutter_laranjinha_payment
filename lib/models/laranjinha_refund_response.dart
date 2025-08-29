import 'package:flutter_laranjinha_payment/constants/laranjinha_status_deeplink.dart';

class LaranjinhaRefundResponse {
  final LaranjinhaStatusDeeplink code;
  final String message;

  LaranjinhaRefundResponse({required this.code, required this.message});

  factory LaranjinhaRefundResponse.fromJson({required Map<String, dynamic> json}) {
    return LaranjinhaRefundResponse(code: _statusFromString(json['code']), message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'code': _statusToString(code), 'message': message};
  }

  static LaranjinhaStatusDeeplink _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'SUCCESS':
        return LaranjinhaStatusDeeplink.SUCCESS;
      case 'ERROR':
        return LaranjinhaStatusDeeplink.ERROR;
      default:
        throw ArgumentError("Invalid status code: $value");
    }
  }

  static String _statusToString(LaranjinhaStatusDeeplink status) {
    return status.name;
  }
}
