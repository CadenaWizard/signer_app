class XpubValidationModel {
  double? timestamp;
  bool? payload;
  String? message;

  XpubValidationModel({this.timestamp, this.payload, this.message});

  XpubValidationModel.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    payload = json['payload'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['payload'] = this.payload;
    data['message'] = this.message;
    return data;
  }
}
