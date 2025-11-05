class UserOfferDlcIdsPoll {
  double? timestamp;
  List<Payload>? payload;
  String? message;

  UserOfferDlcIdsPoll({this.timestamp, this.payload, this.message});

  UserOfferDlcIdsPoll.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    if (json['payload'] != null) {
      payload = <Payload>[];
      json['payload'].forEach((v) {
        payload!.add(new Payload.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    if (this.payload != null) {
      data['payload'] = this.payload!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Payload {
  String? dlcId;
  String? tmpCntrId;
  String? iniRole;
  String? iniEmail;
  String? accEmail;
  String? accPubkey;
  String? orclId;
  // CntrTerms? cntrTerms;
  String? status;
  num? interest;
  num? interestEar;
  num? iniCollateralSats;
  num? accCollateralSats;

  Payload({
    this.dlcId,
    this.tmpCntrId,
    this.iniRole,
    this.iniEmail,
    this.accEmail,
    this.accPubkey,
    this.orclId,
    this.status,
    this.interest,
    this.interestEar,
    this.iniCollateralSats,
    this.accCollateralSats,
  });

  Payload.fromJson(Map<String, dynamic> json) {
    dlcId = json['dlc_id'];
    tmpCntrId = json['tmp_cntr_id'];
    iniRole = json['ini_role'];
    iniEmail = json['ini_email'];
    accEmail = json['acc_email'];
    accPubkey = json['acc_pubkey'];
    orclId = json['orcl_id'];
    // cntrTerms = json['cntr_terms'] != null ? new CntrTerms.fromJson(json['cntr_terms']) : null;
    status = json['status'];
    interest = json['interest'];
    interestEar = json['interest_ear'];
    iniCollateralSats = json['ini_collateral_sats'];
    accCollateralSats = json['acc_collateral_sats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dlc_id'] = this.dlcId;
    data['tmp_cntr_id'] = this.tmpCntrId;
    data['ini_role'] = this.iniRole;
    data['ini_email'] = this.iniEmail;
    data['acc_email'] = this.accEmail;
    data['acc_pubkey'] = this.accPubkey;
    data['orcl_id'] = this.orclId;
    // if (this.cntrTerms != null) {
    //   data['cntr_terms'] = this.cntrTerms!.toJson();
    // }
    data['status'] = this.status;
    data['interest'] = this.interest;
    data['interest_ear'] = this.interestEar;
    data['ini_collateral_sats'] = this.iniCollateralSats;
    data['acc_collateral_sats'] = this.accCollateralSats;
    return data;
  }
}
