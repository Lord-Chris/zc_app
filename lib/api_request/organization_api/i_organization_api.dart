import 'dart:io';

import 'package:zurichat/models/organization_model.dart';
import 'package:zurichat/models/user_search_model.dart';

abstract class IOrganizationRepo {
  // THE SERVICE TO GET LIST OF ORGANIZATIONS
  Future<List<OrganizationModel>> fetchListOfOrganizations();

  // THE SERVICE TO GET LIST OF JOINED ORGANIZATIONS OF A USER
  Future<List<OrganizationModel>> getJoinedOrganizations(String email);

  // THE SERVICE TO GET THE INFORMATION OF AN ORGANIZATION
  Future<OrganizationModel> fetchOrganizationInfo(String id);

  // THE SERVICE TO GET AN ORGANIZATION BY URL
  Future<OrganizationModel> fetchOrganizationByUrl(String url);

  // THE SERVICE TO JOIN AN ORGANIZATION
  Future<bool> joinOrganization(String orgId, String email);

  // THE SERVICE TO CREATE AN ORGANIZATION
  Future<String> createOrganization(String email);

  /// THE SERVICE TO UPDATE AN ORGANIZATION URL
  /// THIS GIVES THE ORGANIZATION A PRIVILEDGE TO
  /// GET A CUSTOM LINK
  ///
  /// AS FAR AS IT IS AVAILABLE FOR USE
  Future<bool> updateOrgUrl(String orgId, String url);

  // THE SERVICE TO UPDATE AN ORGANIZATION NAME
  Future<bool> updateOrgName(String orgId, String name);

  // THE SERVICE TO UPDATE AN ORGANIZATION LOGO
  Future<bool> updateOrgLogo(String orgId, File image);

  // THE SERVICE TO ADD A MEMBERS TO AN ORGANIZATION
  Future<bool> addMemberToOrganization(String orgId, String email);

  // THE SERVICE TO FETCH MEMBERS IN AN ORGANIZATION
  Future<List<UserSearch>> fetchMembersInOrganization(String orgId);

  /// Invites a user to the organzization
  /// This endpoint would sent the user a mail with the UUID
  void inviteToOrganizationWithNormalMail(
      String orgId, List body, String token);
}
