import 'package:flutter_laranjinha_payment/constants/laranjinha_payment_type.dart';

class LaranjinhaPaymentPayload {
  final LaranjinhaPaymentType paymentType;
  final double amount;
  final int? installments;

  LaranjinhaPaymentPayload({required this.paymentType, required this.amount, this.installments}) {
    _validate();
  }

  void _validate() {
    if ((paymentType == LaranjinhaPaymentType.creditInstallments || paymentType == LaranjinhaPaymentType.creditInstallmentsWithInterest) &&
        (installments == null || installments! < 2 || installments! > 99)) {
      throw ArgumentError("Invalid installments: received $installments for paymentType '${paymentType.value}'. Installments must be between 2 and 99.");
    }

    if (amount <= 0) {
      throw ArgumentError("Invalid amount: must be greater than 0 (received $amount)");
    }
  }

  Map<String, dynamic> toJson() {
    final data = {'paymentType': paymentType.value, 'amount': (amount * 100).round(), 'installments': installments};

    return data;
  }

  factory LaranjinhaPaymentPayload.fromJson(Map<String, dynamic> json) {
    return LaranjinhaPaymentPayload(
      paymentType: LaranjinhaPaymentTypeExtension.fromString(json['paymentType']),
      amount: (json['amount'] as int) / 100.0,
      installments: json['installments'],
    );
  }
}
