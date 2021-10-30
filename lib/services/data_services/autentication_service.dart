import 'package:zurichat/api_request/authentication_api/authentication_api.dart';
import 'package:zurichat/api_request/authentication_api/i_authentication_api.dart';
import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/models/user_model.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/services/in_review/user_service.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:zurichat/utilities/failures.dart';

class AuthenticationService {
  final IAuthenticationRepo _authApi = AuthenticationRepo();
  final _userService = locator<UserService>();
  final _storageService = locator<SharedPreferenceLocalStorage>();

  Future<UserModel> login(String email, String password) async {
    final response = await _authApi.login(email: email, password: password);
    _userService.setUserAndToken(
      authToken: response['token'],
      userId: response['id'],
      userEmail: response['email'],
    );

    _storageService.clearData(StorageKeys.currentOrgId);
    final userModel = UserModel.fromJson(response['user']);
    _userService.setUserDetails(userModel);

    return userModel;
  }

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required String phoneNumber,
  }) async {
    final response = await _authApi.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      phoneNumber: phoneNumber,
    );

    _storageService.setString(
        StorageKeys.otp, response?.data['data']['verification_code']);
    _storageService.setString(StorageKeys.currentUserEmail, email);
    _storageService.setBool(StorageKeys.registeredNotverifiedOTP, true);
  }

  Future<bool> resetPassword({required String newPassword}) async {
    await _authApi.resetPassword(newPassword: newPassword);

    return true;
  }

  Future<bool> signOut() async {
    await _authApi.signOut();

    _storageService.clearData(StorageKeys.currentSessionToken);
    _storageService.clearData(StorageKeys.currentUserId);
    _storageService.clearData(StorageKeys.currentUserEmail);
    return true;
  }

  Future<bool> requestOTP({required String email}) async {
    await _authApi.requestOTP(email: email);

    return true;
  }

  Future<bool> verifyOTPCode({required String otpCode}) async {
    await _authApi.verifyOTPCode(otpCode: otpCode);

    return true;
  }
}
