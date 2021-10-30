import 'package:dio/dio.dart';
import 'package:zurichat/utilities/api_handlers/api_utils.dart';
import 'package:zurichat/utilities/api_handlers/dio_interceptors.dart';

import '../../utilities/failures.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService(baseUrl) {
    _dio.options.sendTimeout = 60 * 1000;
    _dio.options.receiveTimeout = 60 * 1000;
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(DioInterceptor());
  }

  /// This method send a **GET** request and returns a value or an error
  /// if it was not successful. It must have a `path` specified. `data` and
  /// `headers` may not be specified.
  Future<dynamic> get(String path,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: data, options: Options(headers: headers));
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      convertException(e);
    }
  }

  /// This method send a **POST** request and returns a value or an error
  /// if it was not successful. It must have a `path` specified. `data` and
  /// `headers` may not be specified.
  ///
  /// `data` can be a _Map_ or a _FormData_
  Future<dynamic> post(String path,
      {dynamic body,
      Map<String, dynamic>? where,
      Map<String, String>? headers}) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        queryParameters: where,
        options: Options(headers: headers),
      );

      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      convertException(e);
    }
  }

  /// This method send a **PATCH** request and returns a value or an error
  /// if it was not successful. It must have a `path` specified. `data` and
  /// `headers` may not be specified.
  ///
  /// `data` can be a _Map_ or a _FormData_
  Future<dynamic> patch(String path,
      {dynamic body,
      Map<String, dynamic>? where,
      Map<String, String>? headers}) async {
    try {
      final response = await _dio.patch(
        path,
        data: body,
        queryParameters: where,
        options: Options(headers: headers),
      );
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      convertException(e);
    }
  }

  /// This method send a **PUT** request and returns a value or an error
  /// if it was not successful. It must have a `path` specified. `data` and
  /// `headers` may not be specified.
  ///
  /// `data` can be a _Map_ or a _FormData_
  Future<dynamic> put(String path,
      {dynamic body,
      Map<String, dynamic>? where,
      Map<String, String>? headers}) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        queryParameters: where,
        options: Options(headers: headers),
      );
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      convertException(e);
    }
  }

  /// This method send a **DELETE** request and returns a value or an error
  /// if it was not successful. It must have a `path` specified. `data` and
  /// `headers` may not be specified.
  ///
  /// `data` can be a _Map_ or a _FormData_
  Future<dynamic> delete(String path,
      {dynamic body,
      Map<String, dynamic>? where,
      Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(
        path,
        data: body,
        queryParameters: where,
        options: Options(headers: headers),
      );
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      convertException(e);
    }
  }

  /// This method handles all possible errors from from a network call.
  Failure convertException(DioError e) {
    switch (e.type) {
      case DioErrorType.cancel:
        throw InputFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.connectTimeout:
        throw NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.receiveTimeout:
        throw NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.sendTimeout:
        throw NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.response:
        throw ServerFailure(
          response: e.response,
          error: e.message,
        );
      default:
        throw UnknownFailure(
          response: e.response,
          error: e.message,
        );
    }
  }
}
