class LinkFieldResponse {
  final String value;
  final String description;

  LinkFieldResponse({this.value, this.description});

  factory LinkFieldResponse.fromJson(Map<String, dynamic> json) {
    return LinkFieldResponse(
      value: json['value'],
      description: json['description'],
    );
  }
}

class DioLinkFieldResponse {
  final List<LinkFieldResponse> values;
  final String error;

  DioLinkFieldResponse(this.values, this.error);

  DioLinkFieldResponse.fromJson(Map<String, dynamic> json)
      : values = (json["results"] as List)
            .map((i) => new LinkFieldResponse.fromJson(i))
            .toList(),
        error = "";

  DioLinkFieldResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetDocResponse {
  final List docs;
  final Map docInfo;

  GetDocResponse({
    this.docs,
    this.docInfo,
  });

  factory GetDocResponse.fromJson(json) {
    return GetDocResponse(
      docs: json['docs'],
      docInfo: json['docinfo'],
    );
  }
}

class DioGetDocResponse {
  final values;
  final String error;

  DioGetDocResponse(this.values, this.error);

  DioGetDocResponse.fromJson(json)
      : values = GetDocResponse.fromJson(json),
        error = "";

  DioGetDocResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetMetaResponse {
  final List docs;
  final String userSettings;

  GetMetaResponse({this.docs, this.userSettings});

  factory GetMetaResponse.fromJson(json) {
    return GetMetaResponse(
      docs: json['docs'],
      userSettings: json['user_settings'],
    );
  }
}

class DioGetMetaResponse {
  final values;
  final String error;

  DioGetMetaResponse(this.values, this.error);

  DioGetMetaResponse.fromJson(json)
      : values = GetMetaResponse.fromJson(json),
        error = "";

  DioGetMetaResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetReportViewResponse {
  final List keys;
  final List values;

  GetReportViewResponse({
    this.keys,
    this.values,
  });

  factory GetReportViewResponse.fromJson(json) {
    if (json.length == 0) {
      return GetReportViewResponse(
        keys: [],
        values: [],
      );
    }
    return GetReportViewResponse(
      keys: json['keys'],
      values: json['values'],
    );
  }
}

class DioGetReportViewResponse {
  var values;
  var error;

  DioGetReportViewResponse(this.values, this.error);

  DioGetReportViewResponse.fromJson(json) {
    var l = json["message"];
    var newL = [];
    for (int i = 0; i < l["values"].length; i++) {
      newL.add([l["keys"], l["values"][i]]);
    }

    values = newL;
    error = '';
  }
  // : values = GetReportViewResponse.fromJson(json["message"]),
  //   error = "";

  DioGetReportViewResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class DioGetContactListResponse {
  final List<LinkFieldResponse> values;
  final String error;

  DioGetContactListResponse(this.values, this.error);

  DioGetContactListResponse.fromJson(Map<String, dynamic> json)
      : values = (json["message"] as List)
            .map((i) => new LinkFieldResponse.fromJson(i))
            .toList(),
        error = "";

  DioGetContactListResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class Contact {
  final String description;
  final String value;

  Contact({this.description, this.value});
}

class DioGetSideBarItemsResponse {
  var values;
  var error;

  DioGetSideBarItemsResponse(this.values, this.error);

  DioGetSideBarItemsResponse.fromJson(json) {
    values = json["message"];
    error = '';
  }

  DioGetSideBarItemsResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class DioDesktopPageResponse {
  var values;
  var error;

  DioDesktopPageResponse(this.values, this.error);

  DioDesktopPageResponse.fromJson(json) {
    values = json["message"];
    error = '';
  }

  DioDesktopPageResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}