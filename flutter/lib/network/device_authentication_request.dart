import 'dart:convert';

import 'package:learn_english/network/application_request.dart';

class DeviceAuthenticationRequest implements ApplicationRequest {
  @override
  String endpoint = "/auth";

  @override
  Method method = Method.post;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;

  DeviceAuthenticationRequest(String deviceToken) {
    body = json.encode({'deviceToken': deviceToken});
  }
}
