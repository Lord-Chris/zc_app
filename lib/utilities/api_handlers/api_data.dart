import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';

class ApiData<T> {
  T? _data;
  late int _statusCode;
  String? _errorMessage;
  late bool _isError;

  ///Return the data instead of response
  ///When an error occurs data is null
  T? get data => _data;

  ///Check whenever there is an error in the response
  bool get isError => _isError;

  ///Get the `statusCode` when there is an error to check
  ///If an error occured use `ApiResponse.isError` instead
  int get statusCode => _statusCode;

  ///Get the error message after checking `ApiResponse.isError`
  String? get errorMessage => _errorMessage;

  ApiData.success({
    required T data,
  }) {
    _data = data;
    _isError = false;
    _errorMessage = null;
    _statusCode = 200;
  }

  ApiData.error(Response? response) {
    _statusCode = response?.statusCode ?? 400;
    _errorMessage =
        response?.data['message'] ?? response?.data['error'] ?? errorOccurred;
    _isError = true;
  }
}
