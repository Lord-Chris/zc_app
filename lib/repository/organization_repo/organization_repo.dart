import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/models/organization_model.dart';
import 'package:zurichat/models/user_search_model.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/services/core_services/api_service.dart';
import 'package:zurichat/utilities/constants/app_constants.dart';
import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:zurichat/utilities/failures.dart';

import '../repo_mixin.dart';
import 'i_organization_repo.dart';

class OrganizationRepo extends IOrganizationRepo with RepoMixin {
  final ApiService _api = ApiService(coreBaseUrl);
  final log = getLogger('OrganizationRepo');

  /// Fetches a list of organizations that exist in the Zuri database
  /// This does not fetch the Organization the user belongs to
  /// To implement that use `getJoinedOrganizations()`
  @override
  Future<List> fetchListOfOrganizations() async {
    try {
      final res = await _api.get('/organizations', headers: headers);
      log.i(res);
      return res?.data?['data'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  ///Get the list of Organization the user has joined
  @override
  Future<List> getJoinedOrganizations(String email) async {
    try {
      final res =
          await _api.get('/users/$email/organizations', headers: headers);
      log.i("RESPONSE !!$res");
      return res?.data?['data'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// Fetches information on a particular Organization. It takes a parameter
  /// `id` which is the id of the organization
  @override
  Future<Map<String, dynamic>> fetchOrganizationInfo(String id) async {
    try {
      final res = await _api.get('/organizations/$id', headers: headers);
      log.i(res);
      return res?.data?['data'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// takes in a `url` and returns a Organization that matches the url
  /// use this url for testing `Zurichat-fsp1856.Zurichat.com`
  @override
  Future<Map<String, dynamic>> fetchOrganizationByUrl(String url) async {
    try {
      final res = await _api.get('/organizations/url/$url', headers: headers);
      log.i(res);

      res?.data?['data']['id'] = res.data['data']['_id'];
      return res?.data?['data'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  ///Limited to the admin who created the org
  ///
  ///This should be used to add users to an organization by the admin user alone
  /// takes in a `Organization id` and joins the Organization
  @override
  Future<bool> joinOrganization(String orgId, String email) async {
    final res = await _api.post('/organizations/$orgId/members',
        body: {'user_email': email}, headers: headers);

    if (res?.statusCode == 200) {
      return true;
    }
    return false;
  }

  /// This method creates an organization. Creator email `email` must be present
  @override
  Future<String> createOrganization(String email) async {
    try {
      final res = await _api.post(
        '/organizations',
        headers: headers,
        body: {'creator_email': email},
      );
      return res?.data?['data']['organization_id'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// Updates an organization's URL. The organization's id `orgId` must not be
  /// null or empty. Url must not begin with `https` or `http`

  @override
  Future<bool> updateOrgUrl(String orgId, String url) async {
    try {
      final res = await _api.patch(
        '/organizations/$orgId/url',
        headers: headers,
        body: {'url': url},
      );

      if (res?.statusCode == 200) {
        return true;
      }
      return false;
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// Updates an organization's name. The organization's id `orgId` must not be
  /// null or empty
  @override
  Future<bool> updateOrgName(String orgId, String name) async {
    try {
      final res = await _api.patch(
        '/organizations/$orgId/name',
        headers: headers,
        body: {'organization_name': name},
      );

      if (res?.statusCode == 200) {
        return true;
      }
      return false;
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// Updates an organization's logo. The organization's id `orgId` must not be
  /// null or empty
  @override
  Future<bool> updateOrgLogo(String orgId, File image) async {
    try {
      var formData = FormData.fromMap({
        'height': 300,
        'width': 300,
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      final res = await _api.patch(
        'organizations/$orgId/logo',
        headers: {'Authorization': 'Bearer $token'},
        body: formData,
      );
      if (res?.statusCode == 200) {
        return true;
      }
      return false;
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// Add members to an organization either through invite
  /// or by calls
  @override
  Future<bool> addMemberToOrganization(String orgId, String email) async {
    try {
      final res = await _api.post(
        '/organizations/$orgId/members',
        headers: headers,
        body: {'user_email': email},
      );
      if (res?.statusCode == 200) {
        return true;
      }
      return false;
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  /// FETCHING MEMBERS

  @override
  Future<List> fetchMembersInOrganization(String orgId) async {
    try {
      final res = await _api.get(
        '/organizations/$orgId/members',
        headers: headers,
      );
      return res?.data?['data'];
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }

  @override
  Future<void> inviteToOrganizationWithNormalMail(
      String orgId, List body, String token) async {
    try {
      final data = {"emails": body};
      final res = await _api.post(
        'organizations/$orgId/send-invite',
        body: data,
        headers: headers,
      );
      log.i(res);
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    } catch (e) {
      log.w(e.toString());
      throw UnknownFailure(errorMessage: e.toString());
    }
  }
}
