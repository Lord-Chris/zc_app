import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/app/app.router.dart';
import 'package:zurichat/services/data_services/autentication_service.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/utilities/api_handlers/zuri_api.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/ui/shared/shared.dart';
import 'package:zurichat/utilities/enums.dart';
import 'package:zurichat/utilities/failures.dart';
import 'package:zurichat/utilities/mixins/validators_mixin.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'forgot_password_newview.form.dart';

class ForgotPasswordNewViewModel extends FormViewModel with ValidatorMixin {
  bool inputError = false;
  final NavigationService _navigationService = NavigationService();
  final _authService = locator<AuthenticationService>();
  final snackbar = locator<SnackbarService>();
  final log = getLogger("Forgot Password New View Model");
  bool isLoading = false;
  final storageService = locator<SharedPreferenceLocalStorage>();
  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);

  loading(status) {
    isLoading = status;
    notifyListeners();
  }

  void navigateToLogin() {
    _navigationService.navigateTo(Routes.loginView);
  }

  void passwordVerification() {
    _passwordValidation();
    notifyListeners();
  }

  void _passwordValidation() {
    bool validatePassword = passValidation(newPasswordValue!);
    if (validatePassword) {
      inputError = !validatePassword;
      navigateToLogin();
    } else {
      inputError = !validatePassword;
      log.e('$inputError');
    }
  }

  Future resetPassword() async {
    loading(true);
    //TODO - wrong endpoint

    if (newPasswordValue == '' || confirmPasswordValue == '') {
      loading(false);
      snackbar.showCustomSnackBar(
        duration: const Duration(seconds: 3),
        variant: SnackbarType.failure,
        message: fillAllFields,
      );
      return;
    } else if (newPasswordValue != confirmPasswordValue) {
      loading(false);
      snackbar.showCustomSnackBar(
        duration: const Duration(seconds: 3),
        variant: SnackbarType.failure,
        message: passwordsMustMatch,
      );
      return;
    }

    try {
      _authService.signOut();

      snackbar.showCustomSnackBar(
        duration: const Duration(seconds: 3),
        variant: SnackbarType.success,
        message: passwordUpdated,
      );
      navigateToLogin();
    } on Failure catch (e) {
      snackbar.showCustomSnackBar(
        message: e.serverMessage,
        variant: SnackbarType.failure,
        duration: const Duration(
          milliseconds: 1500,
        ),
      );
    } catch (e) {
      //catch other errors here so the app can flow smoothely
    }

    // final newPasswordData = {
    //   'password': newPasswordValue,
    //   'confirm_password': confirmPasswordValue
    // };
    // //TODO - CONFIRM ENDPOINT - should be a patch req
    // final response = await _apiService.post(resetPasswordEndpoint,
    //     body: newPasswordData, token: token);
  }

  @override
  void setFormStatus() {}
}
