import 'package:flutter_laranjinha_payment/models/laranjinha_device_info.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_response.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_print_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_laranjinha_payment_method_channel.dart';

abstract class FlutterLaranjinhaPaymentPlatform extends PlatformInterface {
  /// Constructs a FlutterLaranjinhaPaymentPlatform.
  FlutterLaranjinhaPaymentPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLaranjinhaPaymentPlatform _instance = MethodChannelFlutterLaranjinhaPayment();

  /// The default instance of [FlutterLaranjinhaPaymentPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterLaranjinhaPayment].
  static FlutterLaranjinhaPaymentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLaranjinhaPaymentPlatform] when
  /// they register themselves.
  static set instance(FlutterLaranjinhaPaymentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<LaranjinhaPaymentResponse> pay({required LaranjinhaPaymentPayload paymentPayload}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<LaranjinhaRefundResponse> refund({required LaranjinhaRefundPayload refundPayload}) {
    throw UnimplementedError('refund() has not been implemented.');
  }

  Future<void> print({required LaranjinhaPrintPayload printPayload}) {
    throw UnimplementedError('print() has not been implemented.');
  }

  Future<void> reprint() async {
    throw UnimplementedError('reprint() has not been implemented.');
  }

  Future<LaranjinhaDeviceInfo> deviceInfo() {
    throw UnimplementedError('deviceInfo() has not been implemented.');
  }
}
