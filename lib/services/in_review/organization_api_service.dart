import 'dart:io';

import 'package:zurichat/api_request/organization_api/i_organization_api.dart';
import 'package:zurichat/api_request/organization_api/organization_api.dart';
import 'package:zurichat/models/organization_member_model.dart';
import 'package:zurichat/models/user_search_model.dart';
import 'package:zurichat/utilities/api_handlers/zuri_api.dart';
import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../../models/organization_model.dart';
import '../app_services/local_storage_services.dart';
import 'user_service.dart';
import '../../ui/shared/shared.dart';
import '../../utilities/constants/storage_keys.dart';

class OrganizationApiService {
  final log = getLogger('OrganizationApiService');
  final _api = ZuriApi(coreBaseUrl);

  final IOrganizationRepo orgRepo = OrganizationRepo();

  final storageService = locator<SharedPreferenceLocalStorage>();
  final _userService = locator<UserService>();

  /// Fetches a list of organizations that exist in the zuri database
  /// This does not fetch the Organization the user belongs to
  /// To implement that use `getJoinedOrganizations()`
  Future<List<OrganizationModel>> fetchListOfOrganizations() async {
    // final res = await _api.get('/organizations', token: token);
    // log.i(res?.data?['data'].length);
    // return (res?.data?['data'] as List)
    //     .map((e) => OrganizationModel.fromJson(e))
    //     .toList();
    return await orgRepo.fetchListOfOrganizations();
  }

  ///Get the list of Organization the user has joined
  Future<List<OrganizationModel>> getJoinedOrganizations() async {
    final email = _userService.userEmail;

    // final res = await _api.get('/users/$email/organizations', token: token);
    // log.i(res?.data);
    // if (res?.data['data'] == null) {
    //   return [];
    // }
    // return (res?.data?['data'] as List)
    //     .map((e) => OrganizationModel.fromJson(e))
    //     .toList();

    return await orgRepo.getJoinedOrganizations(email);
  }

  /// Fetches information on a particular Organization. It takes a parameter
  /// `id` which is the id of the organization
  Future<OrganizationModel> fetchOrganizationInfo(String id) async {
    // final res = await _api.get('/organizations/$id', token: token);
    // log.i('>>>>>>>>>>>>> Selected Orge $res');
    // return OrganizationModel.fromJson(res?.data?['data']);

    return await orgRepo.fetchOrganizationInfo(id);
  }

  /// takes in a `url` and returns a Organization that matches the url
  /// use this url for testing `zurichat-fsp1856.zurichat.com`
  Future<OrganizationModel> fetchOrganizationByUrl(String url) async {
    // final res = await _api.get('/organizations/url/$url', token: token);
    // log.i(res?.data);

    // res?.data?['data']['id'] = res.data['data']['_id'];
    // return OrganizationModel.fromJson(res?.data?['data']);
    return await orgRepo.fetchOrganizationByUrl(url);
  }

  ///Limited to the admin who created the org
  ///
  ///This should be used to add users to an organization by the admin user alone
  /// takes in a `Organization id` and joins the Organization
  Future<bool> joinOrganization(String orgId) async {
    final email = _userService.userEmail;

    // final res = await _api.post('/organizations/$orgId/members',
    //     body: {'user_email': email}, token: token);

    // if (res?.statusCode == 200) {
    //   return true;
    // }

    // return false;
    return await orgRepo.joinOrganization(orgId, email);
  }

  /// This method creates an organization. Creator email `email` must be present
  ///
  Future<String> createOrganization(String email) async {
    // final res = await _api.post(
    //   '/organizations',
    //   token: token,
    //   body: {'creator_email': email},
    // );
    // return res?.data?['data']['organization_id'];

    return await orgRepo.createOrganization(email);
  }

  /// Updates an organization's URL. The organization's id `orgId` must not be
  /// null or empty. Url must not begin with `https` or `http`
  Future<void> updateOrgUrl(String orgId, String url) async {
    // final res = await _api.patch(
    //   '/organizations/$orgId/url',
    //   token: token,
    //   body: {'url': url},
    // );
    // return res?.data?['message'];
    await orgRepo.updateOrgUrl(orgId, url);
  }

  /// Updates an organization's name. The organization's id `orgId` must not be
  /// null or empty
  Future<void> updateOrgName(String orgId, String name) async {
    // final res = await _api.patch(
    //   '/organizations/$orgId/name',
    //   token: token,
    //   body: {'organization_name': name},
    // );
    // return res?.data?['message'];

    await orgRepo.updateOrgName(orgId, name);
  }

  /// Updates an organization's logo. The organization's id `orgId` must not be
  /// null or empty
  Future<bool> updateOrgLogo(String orgId, File image) async {
    // final res = await _api.patch(
    //   '/organizations/$orgId/logo',
    //   token: token,
    //   body: {'url': url},
    // );
    // return res?.data?['message'];

    return await updateOrgLogo(orgId, image);
  }

  Future<void> addMemberToOrganization(String orgId, String email) async {
    // final res = await _api.post(
    //   '/organizations/$orgId/members',
    //   token: token,
    //   body: {'user_email': email},
    // );
    // return res?.data?['message'];

    await addMemberToOrganization(orgId, email);
  }

  Future<List<UserSearch>> fetchMembersInOrganization(String orgId) async {
    // final res = await _api.get('/organizations/$orgId/members', token: token);
    // if (res?.data['data'] == null) {
    //   return [];
    // }
    // return (res?.data?['data'] as List)
    //     .map((e) => UserSearch.fromJson(e))
    //     .toList();

    return await orgRepo.fetchMembersInOrganization(orgId);
  }

  @Deprecated("use fetch members in an organisation instead")
  Future<OrganizationMemberModelList> getOrganizationMemberList(
      String orgId) async {
    final response = await _api.get('/organizations/$orgId/members');
    return OrganizationMemberModelList.fromJson(response?.data);
  }

  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);
}
