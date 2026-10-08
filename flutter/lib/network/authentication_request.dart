import 'dart:convert';

import 'package:learn_english/network/application_request.dart';

class AuthenticationRequest implements ApplicationRequest {
  @override
  String endpoint = "/auth";

  @override
  Method method = Method.post;

  @override
  Map<String, dynamic> parameters = {};

  @override
  String? body;

  AuthenticationRequest(String token) {
    body = json.encode({'token': token});
  }
}
