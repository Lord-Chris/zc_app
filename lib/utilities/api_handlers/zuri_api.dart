// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/models/api_response.dart';
import 'package:zurichat/ui/shared/shared.dart';
import 'package:zurichat/utilities/api_handlers/api_utils.dart';
import 'package:zurichat/utilities/enums.dart';
import 'package:zurichat/utilities/failures.dart';
import 'package:stacked_services/stacked_services.dart'
    hide FormData, MultipartFile;

import 'api.dart';
import 'dio_interceptors.dart';

class ZuriApi implements Api {
  final log = getLogger('ZuriApi');
  final dio = Dio();
  final snackbar = locator<SnackbarService>();

  StreamController<String> controller = StreamController.broadcast();
  ZuriApi(baseUrl) {
    dio.interceptors.add(DioInterceptor());
    dio.options.sendTimeout = 60000;
    dio.options.receiveTimeout = 60000;
    dio.options.baseUrl = baseUrl;
    log.i('Zuri Api constructed and DIO setup register');
  }

  Future<dynamic> get(
    String string, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    log.i('Making request to $string');
    try {
      final response = await dio.get(string.toString(),
          queryParameters: queryParameters,
          options: token == null
              ? null
              : Options(headers: {'Authorization': 'Bearer $token'}));

      log.i('Response from $string \n${response.data}');
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      if (e.response!.data!['message'] == String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'],
        );
      } else if (e.response!.data!['message'] != String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'] ??
              e.response!.data['error'] ??
              errorOccurred,
        );
      }
      log.w(e.toString());
      handleApiError(e);
    } on SocketException {
      snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 10),
          variant: SnackbarType.failure,
          message: 'Please check your internet');
    }
  }

  Future<dynamic> post(
    String string, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    log.i('Making request to $string');
    try {
      final response = await dio.post(string,
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      log.i('Response from $string \n${response.data}');
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      if (e.response!.data!['message'] == String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'],
        );
      } else if (e.response!.data!['message'] != String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'] ??
              e.response!.data['error'] ??
              errorOccurred,
        );
      }
      log.w(e.toString());
      handleApiError(e);
    } on SocketException {
      snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 10),
          variant: SnackbarType.failure,
          message: 'Please check your internet');
    }
  }

  Future<dynamic> put(
    String string, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    log.i('Making request to $string');
    try {
      final response = await dio.put(string.toString(),
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      log.i('Response from $string \n${response.data}');
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      if (e.response!.data!['message'] == String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'],
        );
      } else if (e.response!.data!['message'] != String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'] ??
              e.response!.data['error'] ??
              errorOccurred,
        );
      }
      log.w(e.toString());
      handleApiError(e);
    } on SocketException {
      snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 10),
          variant: SnackbarType.failure,
          message: 'Please check your internet');
    }
  }

  @override
  Future<ApiResponse?> patch(String path,
      {Map<String, dynamic>? body, String? token}) async {
    try {
      final res = await dio.patch(path,
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ApiUtils.toApiResponse(res);
    } on DioError catch (e) {
      if (e.response!.data!['message'] == String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'],
        );
      } else if (e.response!.data!['message'] != String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'] ??
              e.response!.data['error'] ??
              errorOccurred,
        );
      }
      log.w(e.toString());
      handleApiError(e);
    } on SocketException {
      snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 10),
          variant: SnackbarType.failure,
          message: 'Please check your internet');
    }
  }

  @override
  Future<ApiResponse?> delete(String string,
      {Map<String, dynamic>? body, String? token}) async {
    log.i('Making request to $string');
    try {
      final response = await dio.delete(
        string,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log.i('Response from $string \n${response.data}');
      return ApiUtils.toApiResponse(response);
    } on DioError catch (e) {
      if (e.response!.data!['message'] == String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'],
        );
      } else if (e.response!.data!['message'] != String) {
        snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: e.response!.data!['message'] ??
              e.response!.data['error'] ??
              e.response!.data['detail'] ??
              errorOccurred,
        );
      }
      log.w(e.toString());
      handleApiError(e);
    } on SocketException {
      snackbar.showCustomSnackBar(
          duration: const Duration(seconds: 10),
          variant: SnackbarType.failure,
          message: 'Please check your internet');
    }
  }

  /// -------------------------------------------------------------------------------------------

  /// THE API SERVICES

  /// LOGIN FLOW
  @override

  // THIS SERVICE IS FOR JOINED ROOMS FOR ACTIVE DMs
  Future<List> getActiveRooms(String orgId, String userId, token) async {
    try {
      final res = await get(
              '$dmsBaseUrl/api/v1/org/$orgId/users/$userId/rooms/',
              token: token),
          joinedChannels = res?.data['joined_rooms'] ?? [];
      log.i(joinedChannels);
      return joinedChannels;
    } on DioError catch (e) {
      log.w(e.toString());
      handleApiError(e);
    }
    return [];
  }

  // THIS SERVICE IS FOR THE HOME SCREEN ACTIVE DMs
  @override
  Future<List> getActiveDms(String orgId, token) async {
    try {
      final res =
              await get('$channelsBaseUrl/v1/$orgId/channels/', token: token),
          joinedChannels = res?.data ?? [];
      log.i(joinedChannels);
      return joinedChannels;
    } on DioError catch (e) {
      log.w(e.toString());
      handleApiError(e);
    }

    return [];
  }

  /// Themes for the mobile app
  @override
  List<ThemeData> getThemes() {
    return [
      ThemeData.light().copyWith(
        primaryColor: AppColors.zuriPrimaryColor,
        appBarTheme: const AppBarTheme(
          color: AppColors.whiteColor,
          iconTheme: IconThemeData(color: AppColors.blackColor),
          textTheme: TextTheme(
            headline6: TextStyle(color: AppColors.blackColor, fontSize: 20.0),
          ),
          actionsIconTheme: IconThemeData(color: AppColors.blackColor),
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData().copyWith(
          backgroundColor: AppColors.zuriPrimaryColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.zuriPrimaryColor,
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppColors.zuriPrimaryColor),
      ),
      ThemeData.light(),
      ThemeData.dark(),
      ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: AppColors.kimbieAccent,
          iconTheme: IconThemeData(color: AppColors.blackColor),
          textTheme: TextTheme(
            headline6: TextStyle(color: AppColors.blackColor, fontSize: 20.0),
          ),
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData().copyWith(
          backgroundColor: AppColors.kimbieAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.kimbieAccent,
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppColors.kimbieAccent),
      ),
    ];
  }

  /// Basically send get requests
  @override
  void sendGetRequest(endpoint) async {
    final response = await dio.get(apiBaseUrl + endpoint);
    jsonDecode(response.data);
  }

  @override
  Future sendPostRequest(body, endpoint) async {
    try {
      final response = await dio.post(
        apiBaseUrl + endpoint,
        data: json.encode(body),
      );

      final result = response.data;
      return result;
    } on DioError catch (e) {
      handleApiError(e);
    }
  }

  //!Adjust the patch function as needed
  @override
  Future sendPatchRequest(body, endpoint, userId) async {
    try {
      final response =
          await dio.patch(apiBaseUrl + endpoint, data: json.encode(body));
      final result = response.data;
      return result;
    } on DioError catch (e) {
      handleApiError(e);
    }
  }

  @override
  Failure handleApiError(DioError e) {
    switch (e.type) {
      case DioErrorType.cancel:
        return InputFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.connectTimeout:
        return NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.receiveTimeout:
        return NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.sendTimeout:
        return NetworkFailure(
          response: e.response,
          error: e.message,
        );
      case DioErrorType.response:
        return ServerFailure(
          response: e.response,
          error: e.message,
        );
      default:
        return UnknownFailure(
          response: e.response,
          error: e.message,
        );
    }
  }

  @override
  Future<String> uploadImage(
    File? image, {
    required String token,
    required String pluginId,
  }) async {
    var formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        image!.path,
        filename: image.path.split(Platform.pathSeparator).last,
        contentType: MediaType("image", "jpeg"),
      ),
    });
    try {
      final res = await dio.post(
        '${coreBaseUrl}upload/file/$pluginId',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'token': 'Bearer $token'},
        ),
        data: formData,
      );
      log.i(res.data);
      return res.data['data']['file_url'];
    } on DioError catch (e) {
      log.w(e.toString());
      handleApiError(e);
      return "error uploading the image";
    }
  }
}
