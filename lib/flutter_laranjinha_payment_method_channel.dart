import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_laranjinha_payment_platform_interface.dart';

/// An implementation of [FlutterLaranjinhaPaymentPlatform] that uses method channels.
class MethodChannelFlutterLaranjinhaPayment extends FlutterLaranjinhaPaymentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_laranjinha_payment');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
