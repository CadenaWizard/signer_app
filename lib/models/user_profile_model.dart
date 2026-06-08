class UserProfileModel {
  double? timestamp;
  Payload? payload;
  String? message;

  UserProfileModel({this.timestamp, this.payload, this.message});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    payload = json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    if (this.payload != null) {
      data['payload'] = this.payload!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Payload {
  String? email;
  String? uuid;
  int? authCode;
  String? xpub;
  String? kycStatus;
  int? balanceOnchain;
  int? balanceDerived;
  double? timestamp;
  bool? disabled;

  Payload({
    this.email,
    this.uuid,
    this.authCode,
    this.xpub,
    this.kycStatus,
    this.balanceOnchain,
    this.balanceDerived,
    this.timestamp,
    this.disabled,
  });

  Payload.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    uuid = json['uuid'];
    authCode = json['auth_code'];
    xpub = json['xpub'];
    kycStatus = json['kyc_status'];
    balanceOnchain = json['balance_onchain'];
    balanceDerived = json['balance_derived'];
    timestamp = json['timestamp'];
    disabled = json['disabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['uuid'] = this.uuid;
    data['auth_code'] = this.authCode;
    data['xpub'] = this.xpub;
    data['kyc_status'] = this.kycStatus;
    data['balance_onchain'] = this.balanceOnchain;
    data['balance_derived'] = this.balanceDerived;
    data['timestamp'] = this.timestamp;
    data['disabled'] = this.disabled;
    return data;
  }
}
