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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
