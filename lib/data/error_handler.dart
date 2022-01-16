import 'package:dio/dio.dart';

Error handleDioError(DioError error) {
  switch (error.type) {
    case DioErrorType.connectTimeout:
    case DioErrorType.sendTimeout:
    case DioErrorType.receiveTimeout:
      return TimeoutException();
    case DioErrorType.response:
      var responseCode = error.response?.statusCode;
      if (responseCode == 404) {
        return error.error;
      } else if (responseCode == 409) {
        return ConflictException();
      } else if (responseCode == HTTP_UNAUTHORIZED) {
        return SessionExpiredException();
      } else {
        return GenericError();
      }
    case DioErrorType.cancel:
      return CancelException();
    case DioErrorType.other:
    default:
      return GenericError();

      break;
  }
}

class InvalidSentDataException extends Error {
  final String message;

  InvalidSentDataException(this.message);
}

class CancelException extends Error {}

const HTTP_UNAUTHORIZED = 401;

class SessionExpiredException extends Error {}

class TimeoutException extends Error {}

class ConflictException extends Error {}

class GenericError extends Error {}
