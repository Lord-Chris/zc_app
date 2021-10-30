import 'package:dio/dio.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';

abstract class Failure {
  final Response? response;
  final String? error;

  const Failure({this.error, this.response});

  String get serverMessage =>
      response!.data!['message'] ?? response!.data['error'] ?? errorOccurred;
}

class ServerFailure extends Failure {
  ServerFailure({Response? response, String? error})
      : super(response: response, error: error);

  @override
  String toString() {
    return error ?? '';
  }
}

class InputFailure extends Failure {
  InputFailure({Response? response, String? error})
      : super(response: response, error: error);

  @override
  String toString() {
    return error ?? '';
  }
}

class BadAuthFailure extends Failure {
  BadAuthFailure({Response? response, String? error})
      : super(response: response, error: error);

  @override
  String toString() {
    return error ?? '';
  }
}

class NetworkFailure extends Failure {
  NetworkFailure({Response? response, String? error})
      : super(response: response, error: error);

  @override
  String toString() {
    return error ?? '';
  }
}

class UnknownFailure extends Failure {
  UnknownFailure({Response? response, String? error})
      : super(response: response, error: error);

  @override
  String toString() {
    return error ?? '';
  }
}
