import 'package:flutter_laranjinha_payment/models/laranjinha_content_print.dart';

class LaranjinhaPrintPayload {
  final List<LaranjinhaContentprint> printableContent;

  LaranjinhaPrintPayload({required this.printableContent});

  Map<String, dynamic> toJson() {
    return {'printable_content': printableContent.map((e) => e.toJson()).toList()};
  }

  static LaranjinhaPrintPayload fromJson(Map json) {
    return LaranjinhaPrintPayload(printableContent: json['printable_content'].map<LaranjinhaContentprint>((e) => LaranjinhaContentprint.fromJson(e)).toList());
  }
}
