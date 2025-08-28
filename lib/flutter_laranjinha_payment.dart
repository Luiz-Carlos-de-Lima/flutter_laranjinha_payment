
import 'flutter_laranjinha_payment_platform_interface.dart';

class FlutterLaranjinhaPayment {
  Future<String?> getPlatformVersion() {
    return FlutterLaranjinhaPaymentPlatform.instance.getPlatformVersion();
  }
}
