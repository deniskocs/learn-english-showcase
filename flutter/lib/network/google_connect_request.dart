import 'dart:convert';

import 'package:learn_english/network/application_request.dart';

class GoogleConnectRequest implements ApplicationRequest {
  @override
  String endpoint = "/auth/connect";

  @override
  Method method = Method.post;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;

  GoogleConnectRequest(String googleIdToken, String deviceKey) {
    body = json.encode({
      'googleIdToken': googleIdToken,
      'deviceKey': deviceKey,
    });
  }
}

