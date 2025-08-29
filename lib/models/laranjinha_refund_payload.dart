class LaranjinhaRefundPayload {
  final String nsu;

  LaranjinhaRefundPayload({required this.nsu}) {
    _validate();
  }

  void _validate() {
    if (nsu.length > 6) {
      throw ArgumentError("NSU must not be longer than 6 digits (received '$nsu')");
    }
  }

  factory LaranjinhaRefundPayload.fromJson(Map<String, dynamic> json) {
    return LaranjinhaRefundPayload(nsu: json['nsu']);
  }

  Map<String, dynamic> toJson() {
    return {'nsu': nsu};
  }
}
