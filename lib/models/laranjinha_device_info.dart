class LaranjinhaDeviceInfo {
  final String seriallNumber;
  final String deviceModel;

  LaranjinhaDeviceInfo({required this.seriallNumber, required this.deviceModel});

  static LaranjinhaDeviceInfo fromJson({required Map json}) {
    return LaranjinhaDeviceInfo(seriallNumber: json['serialNumber'], deviceModel: json['deviceModel']);
  }

  Map<String, dynamic> toJson() {
    return {'serialNumber': seriallNumber, 'deviceModel': deviceModel};
  }
}
