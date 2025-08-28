import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laranjinha_payment/flutter_laranjinha_payment.dart';
import 'package:flutter_laranjinha_payment/flutter_laranjinha_payment_platform_interface.dart';
import 'package:flutter_laranjinha_payment/flutter_laranjinha_payment_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLaranjinhaPaymentPlatform
    with MockPlatformInterfaceMixin
    implements FlutterLaranjinhaPaymentPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterLaranjinhaPaymentPlatform initialPlatform = FlutterLaranjinhaPaymentPlatform.instance;

  test('$MethodChannelFlutterLaranjinhaPayment is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterLaranjinhaPayment>());
  });

  test('getPlatformVersion', () async {
    FlutterLaranjinhaPayment flutterLaranjinhaPaymentPlugin = FlutterLaranjinhaPayment();
    MockFlutterLaranjinhaPaymentPlatform fakePlatform = MockFlutterLaranjinhaPaymentPlatform();
    FlutterLaranjinhaPaymentPlatform.instance = fakePlatform;

    expect(await flutterLaranjinhaPaymentPlugin.getPlatformVersion(), '42');
  });
}
