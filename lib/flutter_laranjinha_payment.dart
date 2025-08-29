import 'package:flutter_laranjinha_payment/models/laranjinha_device_info.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_response.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_print_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_response.dart';

import 'flutter_laranjinha_payment_platform_interface.dart';

class FlutterLaranjinhaPayment {
  Future<LaranjinhaPaymentResponse> pay({required LaranjinhaPaymentPayload paymentPayload}) {
    return FlutterLaranjinhaPaymentPlatform.instance.pay(paymentPayload: paymentPayload);
  }

  Future<LaranjinhaRefundResponse> refund({required LaranjinhaRefundPayload refundPayload}) {
    return FlutterLaranjinhaPaymentPlatform.instance.refund(refundPayload: refundPayload);
  }

  Future<void> print({required LaranjinhaPrintPayload printPayload}) {
    return FlutterLaranjinhaPaymentPlatform.instance.print(printPayload: printPayload);
  }

  Future<void> reprint() {
    return FlutterLaranjinhaPaymentPlatform.instance.reprint();
  }

  Future<LaranjinhaDeviceInfo> deviceInfo() {
    return FlutterLaranjinhaPaymentPlatform.instance.deviceInfo();
  }
}
