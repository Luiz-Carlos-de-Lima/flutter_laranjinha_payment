import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_payment_type.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_print_content_types.dart';
import 'package:flutter_laranjinha_payment/constants/laranjinha_status_deeplink.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_content_print.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_payment_response.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_payload.dart';
import 'package:flutter_laranjinha_payment/models/laranjinha_refund_response.dart';

void main() {
  group('LaranjinhaPaymentPayload', () {
    test('toJson converts reais to centavos', () {
      final payload = LaranjinhaPaymentPayload(
        amount: 15.5,
        paymentType: LaranjinhaPaymentType.debit,
      );

      final json = payload.toJson();

      expect(json['amount'], 1550);
      expect(json['paymentType'], 'debit');
    });

    test('toJson keeps credit, pix and voucher types', () {
      expect(
        LaranjinhaPaymentPayload(
          amount: 10,
          paymentType: LaranjinhaPaymentType.creditSinglePayment,
        ).toJson()['paymentType'],
        'credit_single_payment',
      );
      expect(
        LaranjinhaPaymentPayload(
          amount: 10,
          paymentType: LaranjinhaPaymentType.pix,
        ).toJson()['paymentType'],
        'pix',
      );
      expect(
        LaranjinhaPaymentPayload(
          amount: 10,
          paymentType: LaranjinhaPaymentType.voucher,
        ).toJson()['paymentType'],
        'voucher',
      );
    });

    test('fromJson restores amount from centavos', () {
      final payload = LaranjinhaPaymentPayload.fromJson({
        'paymentType': 'debit',
        'amount': 1550,
      });

      expect(payload.amount, 15.5);
      expect(payload.paymentType, LaranjinhaPaymentType.debit);
    });
  });

  group('LaranjinhaPaymentResponse', () {
    test('fromJson and toJson keep payment fields', () {
      final response = LaranjinhaPaymentResponse.fromJson(json: {
        'storeName': 'Loja',
        'date': '01/01/2026',
        'time': '10:00',
        'value': 15.5,
        'auto': 'AUTH',
        'nsu': '123456',
        'issuerName': 'VISA',
        'operationType': 'debit',
      });

      expect(response.value, 15.5);
      expect(response.nsu, '123456');
      expect(response.auto, 'AUTH');

      final restored = LaranjinhaPaymentResponse.fromJson(json: response.toJson());
      expect(restored.value, 15.5);
      expect(restored.nsu, '123456');
    });
  });

  group('LaranjinhaRefundPayload', () {
    test('toJson and fromJson keep nsu', () {
      final payload = LaranjinhaRefundPayload(nsu: '123456');
      final restored = LaranjinhaRefundPayload.fromJson(payload.toJson());
      expect(restored.nsu, '123456');
    });
  });

  group('LaranjinhaRefundResponse', () {
    test('fromJson and toJson keep status', () {
      final response = LaranjinhaRefundResponse.fromJson(json: {
        'code': 'SUCCESS',
        'message': 'ok',
      });
      expect(response.code, LaranjinhaStatusDeeplink.SUCCESS);
      expect(response.toJson()['code'], 'SUCCESS');
    });
  });

  group('LaranjinhaContentprint', () {
    test('toJson keeps text fields', () {
      final content = LaranjinhaContentprint(
        type: LaranjinhaPrintType.text,
        content: 'Cupom',
        align: LaranjinhaPrintAlign.center,
        size: LaranjinhaPrintSize.big,
        ignoreLineBreak: true,
      );

      final json = content.toJson();
      expect(json['type'], 'text');
      expect(json['content'], 'Cupom');
      expect(json['align'], 'center');
      expect(json['size'], 'big');
    });
  });
}
