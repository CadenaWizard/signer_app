class DlcSignatureResponseModel {
  bool? payload;
  String? message;
  num? timestamp;
  String? detail;

  DlcSignatureResponseModel({
    this.payload,
    this.message,
    this.timestamp,
    this.detail,
  });

  DlcSignatureResponseModel.fromJson(Map<String, dynamic> json) {
    payload = json['payload'];
    message = json['message'];
    timestamp = json['timestamp'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payload'] = payload;
    data['message'] = message;
    data['timestamp'] = timestamp;
    data['detail'] = detail;
    return data;
  }
}
