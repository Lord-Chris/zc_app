import 'dart:async';

import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/app/app.router.dart';
import 'package:zurichat/services/data_services/autentication_service.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/utilities/api_handlers/zuri_api.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/ui/shared/shared.dart';
import 'package:zurichat/ui/view/otp/otp_view.form.dart';
import 'package:zurichat/utilities/enums.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zurichat/utilities/failures.dart';

class ForgotPasswordOtpViewModel extends FormViewModel {
  final NavigationService _navigationService = NavigationService();
  final _authService = locator<AuthenticationService>();
  final _snackbarService = locator<SnackbarService>();
  bool isLoading = false;
  final storageService = locator<SharedPreferenceLocalStorage>();
  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);

  StreamController<ErrorAnimationType>? errorController;

  loading(status) {
    isLoading = status;
    notifyListeners();
  }

  void navigateToNewPassword() {
    _navigationService.navigateTo(Routes.forgotPasswordNewView);
  }

  Future verifyOtpCode() async {
    loading(true);

    if (otpValue == '') {
      loading(false);
      _snackbarService.showCustomSnackBar(
          duration: const Duration(seconds: 3),
          variant: SnackbarType.failure,
          message: fillAllFields);
      return;
    }
    notifyListeners();

    // final validationData = {'code': otpValue};
    // final response = await _apiService.post(verifyOTPEndpoint,
    //     body: validationData, token: token);
    try {
      _authService.signOut();
      _snackbarService.showCustomSnackBar(
        duration: const Duration(seconds: 2),
        variant: SnackbarType.success,
        message: EnterNewPassword,
      );
      navigateToNewPassword();
    } on Failure catch (e) {
      _snackbarService.showCustomSnackBar(
        message: e.serverMessage,
        variant: SnackbarType.failure,
        duration: const Duration(
          milliseconds: 1500,
        ),
      );
    } catch (e) {
      //catch other errors here so the app can flow smoothely
    }

    loading(false);
  }

  @override
  void setFormStatus() {}
}
