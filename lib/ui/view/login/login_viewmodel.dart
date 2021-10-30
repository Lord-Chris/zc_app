import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/services/data_services/autentication_service.dart';
import 'package:zurichat/utilities/constants/app_strings.dart';
import 'package:zurichat/models/user_model.dart';
import 'package:zurichat/services/in_review/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zurichat/utilities/failures.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/app_services/connectivity_service.dart';
import '../../../services/app_services/local_storage_services.dart';
import '../../../utilities/enums.dart';
import '../../../utilities/constants/storage_keys.dart';
import 'login_view.form.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  final _storageService = locator<SharedPreferenceLocalStorage>();
  final _snackbarService = locator<SnackbarService>();
  final _connectivityService = locator<ConnectivityService>();
  final storageService = locator<SharedPreferenceLocalStorage>();
  final _userService = locator<UserService>();
  final _authService = locator<AuthenticationService>();
  // final zuriApi = AuthenticationRepo();
  late UserModel userModel;

  final log = getLogger('LogInViewModel');

  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);

  bool isLoading = false;

  loading(status) {
    isLoading = status;
    notifyListeners();
  }

  Future initialise() async {
    var hasUser = _userService.hasUser;
    return hasUser;
  }

  void navigateToHomeScreen() {
    _navigationService.navigateTo(Routes.navBarView);
  }

  void navigateToSignUpScreen() {
    _navigationService.navigateTo(Routes.signUpView);
  }

  void navigateToForgotPasswordScreen() {
    _navigationService.navigateTo(Routes.forgotPasswordEmailView);
  }

  Future logInUser() async {
    var connected = await _connectivityService.checkConnection();
    if (!connected) {
      _snackbarService.showCustomSnackBar(
        message: noInternet,
        variant: SnackbarType.failure,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }
    loading(true);

    if (emailValue == null ||
        passwordValue == null ||
        emailValue == '' ||
        passwordValue == '') {
      loading(false);
      _snackbarService.showCustomSnackBar(
        duration: const Duration(milliseconds: 1500),
        variant: SnackbarType.failure,
        message: fillAllFields,
      );
      return;
    }

    try {
      final userModel = await _authService.login(emailValue!, passwordValue!);

      _snackbarService.showCustomSnackBar(
        duration: const Duration(milliseconds: 1500),
        variant: SnackbarType.success,
        message: '''Login Succesful for ${userModel.email}''',
      );

      //TODO check if user has currently joined an Organization
      _navigationService.pushNamedAndRemoveUntil(Routes.organizationView);
    } on Failure catch (e) {
      _snackbarService.showCustomSnackBar(
        duration: const Duration(milliseconds: 1500),
        variant: SnackbarType.failure,
        message: e.serverMessage,
      );
    } catch (e) {
      //catch all other errors here so app can go on smoothely
    }

    loading(false);
  }

  @override
  void setFormStatus() {}
}
