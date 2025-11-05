class AppVersionEPModel {
  AppVersionData? payload;
  String? message;
  num? timestamp;

  AppVersionEPModel({this.payload, this.message, this.timestamp});

  AppVersionEPModel.fromJson(Map<String, dynamic> json) {
    payload =
    json['payload'] != null ? new AppVersionData.fromJson(json['payload']) : null;
    message = json['message'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.payload != null) {
      data['payload'] = this.payload!.toJson();
    }
    data['message'] = this.message;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class AppVersionData {
  String? appVersionNrNewest;
  num? apiVersionNr;
  Endpoints? endpoints;

  AppVersionData({this.appVersionNrNewest, this.apiVersionNr, this.endpoints});

  AppVersionData.fromJson(Map<String, dynamic> json) {
    appVersionNrNewest = json['app_version_nr_newest'];
    apiVersionNr = json['api_version_nr'];
    endpoints = json['endpoints'] != null
        ? new Endpoints.fromJson(json['endpoints'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['app_version_nr_newest'] = this.appVersionNrNewest;
    data['api_version_nr'] = this.apiVersionNr;
    if (this.endpoints != null) {
      data['endpoints'] = this.endpoints!.toJson();
    }
    return data;
  }
}

class Endpoints {
  GETSERVICEVERSIONINFO? gETSERVICEVERSIONINFO;
  GETSERVICEVERSIONINFO? gETXPUBVALIDATION;
  GETSERVICEVERSIONINFO? pOSTUSERAUTHSUPGRADE;
  GETSERVICEVERSIONINFO? gETUSEROFFERDLCIDSPOLL;
  GETSERVICEVERSIONINFO? gETUSERRELATEDDLCBYID;
  GETSERVICEVERSIONINFO? gETUSERSIGREQSBYIDLIST;
  GETSERVICEVERSIONINFO? pOSTOFFERDLCSIGNATURES;

  Endpoints(
      {this.gETSERVICEVERSIONINFO,
        this.gETXPUBVALIDATION,
        this.pOSTUSERAUTHSUPGRADE,
        this.gETUSEROFFERDLCIDSPOLL,
        this.gETUSERRELATEDDLCBYID,
        this.gETUSERSIGREQSBYIDLIST,
        this.pOSTOFFERDLCSIGNATURES});

  Endpoints.fromJson(Map<String, dynamic> json) {
    gETSERVICEVERSIONINFO = json['GET_SERVICE_VERSION_INFO'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(json['GET_SERVICE_VERSION_INFO'])
        : null;
    gETXPUBVALIDATION = json['GET_XPUB_VALIDATION'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(json['GET_XPUB_VALIDATION'])
        : null;
    pOSTUSERAUTHSUPGRADE = json['POST_USER_AUTH_S_UPGRADE'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(json['POST_USER_AUTH_S_UPGRADE'])
        : null;
    gETUSEROFFERDLCIDSPOLL = json['GET_USER_OFFER_DLC_IDS_POLL'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(
        json['GET_USER_OFFER_DLC_IDS_POLL'])
        : null;
    gETUSERRELATEDDLCBYID = json['GET_USER_RELATED_DLC_BY_ID'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(json['GET_USER_RELATED_DLC_BY_ID'])
        : null;
    gETUSERSIGREQSBYIDLIST = json['GET_USER_SIGREQS_BY_ID_LIST'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(
        json['GET_USER_SIGREQS_BY_ID_LIST'])
        : null;
    pOSTOFFERDLCSIGNATURES = json['POST_OFFER_DLC_SIGNATURES'] != null
        ? new GETSERVICEVERSIONINFO.fromJson(json['POST_OFFER_DLC_SIGNATURES'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gETSERVICEVERSIONINFO != null) {
      data['GET_SERVICE_VERSION_INFO'] = this.gETSERVICEVERSIONINFO!.toJson();
    }
    if (this.gETXPUBVALIDATION != null) {
      data['GET_XPUB_VALIDATION'] = this.gETXPUBVALIDATION!.toJson();
    }
    if (this.pOSTUSERAUTHSUPGRADE != null) {
      data['POST_USER_AUTH_S_UPGRADE'] = this.pOSTUSERAUTHSUPGRADE!.toJson();
    }
    if (this.gETUSEROFFERDLCIDSPOLL != null) {
      data['GET_USER_OFFER_DLC_IDS_POLL'] =
          this.gETUSEROFFERDLCIDSPOLL!.toJson();
    }
    if (this.gETUSERRELATEDDLCBYID != null) {
      data['GET_USER_RELATED_DLC_BY_ID'] = this.gETUSERRELATEDDLCBYID!.toJson();
    }
    if (this.gETUSERSIGREQSBYIDLIST != null) {
      data['GET_USER_SIGREQS_BY_ID_LIST'] =
          this.gETUSERSIGREQSBYIDLIST!.toJson();
    }
    if (this.pOSTOFFERDLCSIGNATURES != null) {
      data['POST_OFFER_DLC_SIGNATURES'] = this.pOSTOFFERDLCSIGNATURES!.toJson();
    }
    return data;
  }
}

class GETSERVICEVERSIONINFO {
  String? url;

  GETSERVICEVERSIONINFO({this.url});

  GETSERVICEVERSIONINFO.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}