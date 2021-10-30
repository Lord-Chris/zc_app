import 'dart:developer';

import 'package:zurichat/models/api_response.dart';
import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/services/core_services/api_service.dart';
import 'package:zurichat/utilities/api_handlers/api_data.dart';
import 'package:zurichat/utilities/constants/app_constants.dart';

import 'package:dio/dio.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/utilities/failures.dart';
import '../api_mixin.dart';
import 'i_authentication_api.dart';

class AuthenticationRepo extends IAuthenticationRepo with RepoMixin {
  final ApiService _apiService = ApiService(coreBaseUrl);
  final log = getLogger('OrganizationRepo');

  @override
  Future<Map> login(
      {required String email, required String password, token}) async {
    final response = await _apiService.post(
      "auth/login",
      body: {
        "email": email,
        "password": password,
      },
      headers: headers,
    );

    ///T: convert this to a model
    return response.data['data']['user'];
  }

  @override
  Future<dynamic> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required String phoneNumber,
  }) async {
    return await _apiService.post(
      "/users",
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'display_name': displayName,
        'email': email,
        'password': password,
        'phone': phoneNumber,
      },
    );
  }

  @override
  Future<bool> resetPassword({required String newPassword}) async {
    final newPasswordData = {
      'password': newPassword,
      'confirm_password': newPassword,
    };

    await _apiService.post(resetPasswordEndpoint,
        body: newPasswordData, headers: headers);

    return true;
  }

  @override
  Future<bool> signOut() async {
    const endpoint = "/auth/logout";
    await _apiService.post(endpoint);

    return true;
  }

  @override
  Future<bool> requestOTP({required String email}) async {
    final validationData = {'email': email};
    await _apiService.post(requestOTPEndpoint,
        body: validationData, headers: headers);

    return true;
  }

  @override
  Future<bool> verifyOTPCode({required String otpCode}) async {
    final validationData = {'code': otpCode};
    await _apiService.post(verifyOTPEndpoint,
        body: validationData, headers: headers);

    return true;
  }
}
