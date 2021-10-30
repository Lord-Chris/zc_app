import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/app/app.router.dart';
import 'package:zurichat/services/data_services/autentication_service.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/utilities/api_handlers/zuri_api.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/ui/shared/shared.dart';
import 'package:zurichat/ui/view/forgot_password/forgot_password_email/forgot_password_email_view.form.dart';
import 'package:zurichat/utilities/enums.dart';
import 'package:zurichat/utilities/failures.dart';
import 'package:zurichat/utilities/mixins/validators_mixin.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ForgotPasswordEmailViewModel extends FormViewModel with ValidatorMixin {
  bool inputError = false;
  final _authService = locator<AuthenticationService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  bool isLoading = false;
  final storageService = locator<SharedPreferenceLocalStorage>();
  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);

  loading(status) {
    isLoading = status;
    notifyListeners();
  }

  Future validateEmailIsRegistered() async {
    loading(true);

    if (forgotEmailValue == '') {
      loading(false);
      _snackbarService.showCustomSnackBar(
        duration: const Duration(seconds: 2),
        variant: SnackbarType.failure,
        message: fillAllFields,
      );
      return;
    } else if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_"
            r"`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(forgotEmailValue!)) {
      loading(true);
    } else {
      loading(false);
      _snackbarService.showCustomSnackBar(
        duration: const Duration(seconds: 2),
        variant: SnackbarType.failure,
        message: invalidEmailFormat,
      );
      return;
    }

    // final validationData = {'email': forgotEmailValue};
    // final response = await _apiService.post(requestOTPEndpoint,
    //     body: validationData, token: token);

    try {
      _authService.signOut();
      _snackbarService.showCustomSnackBar(
        duration: const Duration(seconds: 2),
        variant: SnackbarType.success,
        message: checkEmailForOTP,
      );

      navigateToForgotPasswordOtpView();
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

  void navigateToForgotPasswordOtpView() =>
      _navigationService.navigateTo(Routes.forgotPasswordOtpView);

  void navigateToSignIn() => _navigationService.navigateTo(Routes.loginView);
}
