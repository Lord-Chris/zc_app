import 'package:dio/dio.dart';

import 'package:stacked/stacked.dart';
import 'package:zurichat/api_request/organization_api/organization_api.dart';
import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/app/app.router.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/services/in_review/user_service.dart';
import 'package:zurichat/utilities/mixins/validators_mixin.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';

import '../../../../../../app/app.logger.dart';
import 'package:stacked_services/stacked_services.dart';

class InviteViewModel extends FormViewModel with ValidatorMixin {
  final storage = locator<SharedPreferenceLocalStorage>();
  final userService = locator<UserService>();
  final navigationService = locator<NavigationService>();
  final snackbar = locator<SnackbarService>();
  final log = getLogger('InviteEmailView');
  final _zuriApi = OrganizationRepo();

  Future<void> inviteWithMail(String email) async {
    final orgId = userService.currentOrgId;
    final token = userService.authToken;
    await storage.clearData(StorageKeys.invitedEmail);
    if (validateEmail(email) == null) {
      setBusy(true);

      List body = [email];
      try {
        await _zuriApi.inviteToOrganizationWithNormalMail(orgId, body, token);
        setBusy(false);

        await storage.setString(StorageKeys.invitedEmail, email);
        navigateToInvitationSent();
      } on DioError catch (e) {
        log.w(e.toString());
        setBusy(false);
      }
    }
  }

// String get selectedEmail =>
  String? getInvitedMail() {
    return storage.getString(StorageKeys.invitedEmail) ?? '';
  }

  void navigateBack() {
    navigationService.back();
  }

  void navigateToHome() {
    navigationService.popRepeated(2);
  }

  void navigateToContacts() {
    navigationService.navigateTo(Routes.importContacts);
  }

  void navigateToInvitationSent() {
    navigationService.navigateTo(Routes.invitationSent);
  }

  @override
  void setFormStatus() {
    // TODO: implement setFormStatus
  }
}
