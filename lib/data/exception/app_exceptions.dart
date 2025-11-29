abstract class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix $_message ";
  }
}

class FetchDataException extends AppException {
  FetchDataException({String? message})
      : super(message, 'Error During Communication');
}

class EmptyTOCException extends AppException {
  EmptyTOCException()
      : super("Terms & Conditions are currently unavailable.",
            "Please try again later.");
}

class BadRequestException extends AppException {
  BadRequestException({String? message}) : super(message, "Invalid Request");
}

class UnAuthorizesException extends AppException {
  UnAuthorizesException({String? message}) : super(message, "");
}

class InvalidInputException extends AppException {
  InvalidInputException({String? message}) : super(message, "Invalid Input");
}

class DefaultException extends AppException {
  DefaultException({String? message}) : super(message, "");
}
