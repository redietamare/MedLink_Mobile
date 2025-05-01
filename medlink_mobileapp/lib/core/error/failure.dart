abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(String message) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure() : super('Authorization required.');
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;
  ValidationFailure(this.errors) : super('Invalid input provided.');
}