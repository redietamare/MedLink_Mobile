class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}
class UnauthorizedException implements Exception {}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;
  ValidationException(this.errors);
}