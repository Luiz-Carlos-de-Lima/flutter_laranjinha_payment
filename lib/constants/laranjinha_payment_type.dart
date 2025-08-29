enum LaranjinhaPaymentType { creditSinglePayment, creditInstallments, creditInstallmentsWithInterest, debit, voucher, pix }

extension LaranjinhaPaymentTypeExtension on LaranjinhaPaymentType {
  String get value {
    switch (this) {
      case LaranjinhaPaymentType.creditSinglePayment:
        return 'credit_single_payment';
      case LaranjinhaPaymentType.creditInstallments:
        return 'credit_installments';
      case LaranjinhaPaymentType.creditInstallmentsWithInterest:
        return 'credit_installments_with_interest';
      case LaranjinhaPaymentType.debit:
        return 'debit';
      case LaranjinhaPaymentType.voucher:
        return 'voucher';
      case LaranjinhaPaymentType.pix:
        return 'pix';
    }
  }

  static LaranjinhaPaymentType fromString(String value) {
    switch (value) {
      case 'credit_single_payment':
        return LaranjinhaPaymentType.creditSinglePayment;
      case 'credit_installments':
        return LaranjinhaPaymentType.creditInstallments;
      case 'credit_installments_with_interest':
        return LaranjinhaPaymentType.creditInstallmentsWithInterest;
      case 'debit':
        return LaranjinhaPaymentType.debit;
      case 'voucher':
        return LaranjinhaPaymentType.voucher;
      case 'pix':
        return LaranjinhaPaymentType.pix;
      default:
        throw ArgumentError("Invalid paymentType: '$value'");
    }
  }
}
