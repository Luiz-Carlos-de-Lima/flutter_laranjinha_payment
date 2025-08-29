class LaranjinhaPaymentResponse {
  final String storeName;
  final String date;
  final String time;
  final double value;
  final String? auto; // Opcional (não disponível em Pix)
  final String? nsu;
  final String? issuerName;
  final String? cardHolderName; // Opcional em Pix
  final String? terminalNumber;
  final String? cv; // Opcional
  final String? aid; // Opcional (não disponível em Pix)
  final String? arqc; // Opcional (não disponível em Pix)
  final int? installments; // Opcional (não disponível em Pix)
  final double? installmentValue; // Opcional (não disponível em Pix)
  final String? cnpj;
  final String? operationType;
  final String? maskedPan;
  final String? pixTransactionId; // Disponível apenas em Pix

  LaranjinhaPaymentResponse({
    required this.storeName,
    required this.date,
    required this.time,
    required this.value,
    this.auto,
    this.nsu,
    this.issuerName,
    this.cardHolderName,
    this.terminalNumber,
    this.cv,
    this.aid,
    this.arqc,
    this.installments,
    this.installmentValue,
    this.cnpj,
    this.operationType,
    this.maskedPan,
    this.pixTransactionId,
  });

  factory LaranjinhaPaymentResponse.fromJson({required Map<String, dynamic> json}) {
    return LaranjinhaPaymentResponse(
      storeName: json['storeName'],
      date: json['date'],
      time: json['time'],
      value: (json['value'] as num).toDouble(),
      auto: json['auto'],
      nsu: json['nsu'],
      issuerName: json['issuerName'],
      cardHolderName: json['cardHolderName'],
      terminalNumber: json['terminalNumber'],
      cv: json['cv'],
      aid: json['aid'],
      arqc: json['arqc'],
      installments: json['installments'],
      installmentValue: json['installmentValue'] != null ? (json['installmentValue'] as num).toDouble() : null,
      cnpj: json['cnpj'],
      operationType: json['operationType'],
      maskedPan: json['maskedPan'],
      pixTransactionId: json['pixTransactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'date': date,
      'time': time,
      'value': value,
      'auto': auto,
      'nsu': nsu,
      'issuerName': issuerName,
      'cardHolderName': cardHolderName,
      'terminalNumber': terminalNumber,
      'cv': cv,
      'aid': aid,
      'arqc': arqc,
      'installments': installments,
      'installmentValue': installmentValue,
      'cnpj': cnpj,
      'operationType': operationType,
      'maskedPan': maskedPan,
      'pixTransactionId': pixTransactionId,
    };
  }
}
