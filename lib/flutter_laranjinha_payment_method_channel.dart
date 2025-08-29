import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_status_deeplink.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_info_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_payment_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_print_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_refund_exception.dart';
import 'package:flutter_laranjinha_payment/exceptions/laranjinha_reprint_exception.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_device_info.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_response.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_print_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_response.dart';

import 'flutter_laranjinha_payment_platform_interface.dart';

/// An implementation of [FlutterLaranjinhaPaymentPlatform] that uses method channels.
class MethodChannelFlutterLaranjinhaPayment extends FlutterLaranjinhaPaymentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_laranjinha_payment');

  @override
  Future<LaranjinhaPaymentResponse> pay({required LaranjinhaPaymentPayload paymentPayload}) async {
    try {
      final response = await methodChannel.invokeMethod<Map>('pay', paymentPayload.toJson());
      if (response is Map) {
        if (response['code'] == LaranjinhaStatusDeeplink.SUCCESS.name) {
          final jsonData = Map.from(response['data']);
          return LaranjinhaPaymentResponse.fromJson(json: jsonData.cast());
        } else {
          throw LaranjinhaPaymentException(message: response['message']);
        }
      } else {
        throw LaranjinhaRefundException(message: 'invalid response');
      }
    } on LaranjinhaPaymentException catch (e) {
      throw LaranjinhaPaymentException(message: e.message);
    } on PlatformException catch (e) {
      throw LaranjinhaPaymentException(message: e.message ?? 'PlatformException');
    } catch (e) {
      throw LaranjinhaPaymentException(message: "Pay Error: $e");
    }
  }

  @override
  Future<LaranjinhaRefundResponse> refund({required LaranjinhaRefundPayload refundPayload}) async {
    try {
      final refund = refundPayload.toJson();
      final response = await methodChannel.invokeMethod<Map>('refund', refund);
      if (response is Map) {
        if (response['code'] == LaranjinhaStatusDeeplink.SUCCESS.name) {
          final jsonData = Map.from(response['data']);
          return LaranjinhaRefundResponse.fromJson(json: jsonData.cast());
        } else {
          throw LaranjinhaRefundException(message: response['message']);
        }
      } else {
        throw LaranjinhaRefundException(message: 'invalid response');
      }
    } on LaranjinhaRefundException catch (e) {
      throw LaranjinhaRefundException(message: e.message);
    } on PlatformException catch (e) {
      throw LaranjinhaRefundException(message: e.message ?? 'PlatformException');
    } catch (e) {
      throw LaranjinhaRefundException(message: "Status payment Error: $e");
    }
  }

  @override
  Future<void> print({required LaranjinhaPrintPayload printPayload}) async {
    try {
      final response = await methodChannel.invokeMethod<Map>('print', printPayload.toJson());

      if (response is Map) {
        if (response['code'] != LaranjinhaStatusDeeplink.SUCCESS.name) {
          throw LaranjinhaPrintException(message: response['message']);
        }
      } else {
        throw LaranjinhaPrintException(message: 'invalid response');
      }
    } on LaranjinhaPrintException catch (e) {
      throw LaranjinhaPrintException(message: e.message);
    } on PlatformException catch (e) {
      throw LaranjinhaPrintException(message: e.message ?? 'PlatformException');
    } catch (e) {
      throw LaranjinhaPrintException(message: "Print Error: $e");
    }
  }

  @override
  Future<void> reprint() async {
    try {
      final response = await methodChannel.invokeMethod<Map>('reprint');
      if (response is Map) {
        if (response['code'] == LaranjinhaStatusDeeplink.ERROR.name) {
          throw LaranjinhaReprintException(message: response['message']);
        }
      } else {
        throw LaranjinhaReprintException(message: 'invalid response');
      }
    } on LaranjinhaReprintException catch (e) {
      throw LaranjinhaReprintException(message: e.message);
    } on PlatformException catch (e) {
      throw LaranjinhaReprintException(message: e.message ?? 'PlatformException');
    } catch (e) {
      throw LaranjinhaReprintException(message: "reprint payment Error: $e");
    }
  }

  @override
  Future<LaranjinhaDeviceInfo> deviceInfo() async {
    try {
      final response = await methodChannel.invokeMethod<Map>('getSerialNumberAndDeviceModel');
      if (response is Map) {
        if ((response['code'] == LaranjinhaStatusDeeplink.SUCCESS.name) && response['data'] is Map) {
          final jsonData = response['data'];
          return LaranjinhaDeviceInfo.fromJson(json: jsonData);
        } else {
          throw LaranjinhaInfoException(message: response['message']);
        }
      } else {
        throw LaranjinhaInfoException(message: 'invalid response');
      }
    } on LaranjinhaInfoException catch (e) {
      throw LaranjinhaInfoException(message: e.message);
    } on PlatformException catch (e) {
      throw LaranjinhaInfoException(message: e.message ?? 'PlatformException');
    } catch (e) {
      throw LaranjinhaInfoException(message: "deviceInfo payment Error: $e");
    }
  }
}
