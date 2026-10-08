enum Method {
  get,
  post
}

abstract class ApplicationRequest {
  abstract String endpoint;
  abstract Method method;
  abstract String? body;
  abstract Map<String, dynamic> parameters;
}
