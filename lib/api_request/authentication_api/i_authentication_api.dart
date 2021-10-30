import 'package:zurichat/utilities/api_handlers/api_data.dart';

abstract class IAuthenticationRepo {
  // LOGIN SERVICE
  Future<Map> login({required String email, required String password, token});

  // SIGNUP SERVICE
  Future<dynamic> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required String phoneNumber,
  });

  Future<bool> signOut();

  Future<bool> requestOTP({required String email});

  Future<bool> resetPassword({required String newPassword});

  Future<bool> verifyOTPCode({required String otpCode});
}
