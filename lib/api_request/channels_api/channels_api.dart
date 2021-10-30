import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/models/channel_members.dart';
import 'package:zurichat/models/channels_search_model.dart';
import 'package:zurichat/models/pinned_message_model.dart';
import 'package:zurichat/models/user_search_model.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/services/core_services/api_service.dart';
import 'package:zurichat/utilities/constants/app_constants.dart';
import 'package:zurichat/app/app.logger.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';
import 'package:zurichat/utilities/failures.dart';

import 'i_channels_api.dart';

class ChannelsRepo extends IChannelsRepo {
  final ApiService _service = ApiService(channelsBaseUrl);
  final _log = getLogger('ChannelsRepo');
  final _storageService = locator<SharedPreferenceLocalStorage>();

  @override
  Future<dynamic> addMemberToChannel(
      String channelId, String orgId, String userId) async {
    final headers = {'Authorization': 'Bearer $token'};
    final res = await _service.post(
      "$channelsBaseUrl/v1/$orgId/channels/$channelId/members/",
      //  "/614679ee1a5607b13c00bcb7/channels/$channelId/members/",
      headers: headers,
      body: {
        "_id": userId,
        "is_admin": false,
        "notifications": {
          "web": "nothing",
          "mobile": "mentions",
          "same_for_mobile": true,
          "mute": false
        }
      },
    );
    return res;
  }

  /// THIS BASICALLY HANDLES CHANNEL SOCKETS FOR RTC
  /// THIS BASICALLY HANDLES CHANNEL SOCKETS FOR RTC
  @override
  Future<String?> getChannelSocketId(String channelId, String orgId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.get(
        '$websocketUrl/v1/$orgId/channels/$channelId/socket/',
        headers: headers,
      );
      _log.i(res['socket_name']);
      return res['socket_name'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  // Joins a channel using the parameters below
  @override
  Future<Map> joinChannel(String channelId, String userId, String orgId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.post(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/members/',
        headers: headers,
        body: {'_id': userId, 'is_admin': true},
      );
      _log.i(res);
      return res;
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Getting Channel messages is this function below.
  /// The Channel ID must not be null
  @override
  Future<List?> getChannelMessages(String channelId, String orgId) async {
    try {
      final res = await _service.get(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/messages/',
        headers: {'Authorization': 'Bearer $token'},
      );
      _log.i(res['data']);
      return res['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Sends channels message
  /// Channel ID, User ID, Org ID must not be null
  @override
  Future sendChannelMessages(
      String channelId, String userId, String orgId, String message,
      [List<String>? media]) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.post(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/messages/',
        body: {'user_id': userId, 'content': message, "files": media},
        headers: headers,
      );
      _log.i(res['data']);
      return res['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future<List> getRepliesToMessages(String orgId, String messageId) async {
    try {
      final res = await _service.get(
        '/v1/$orgId/messages/$messageId/threads/',
      );
      return res['data'] ?? [];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> addReplyToMessage(String? messageId, String orgId,
      String channelId, String userId, String? content, files) async {
    try {
      await _service.post(
        '/v1/$orgId/messages/$messageId/threads/',
        where: {"channel_id": channelId},
        body: {
          'user_id': userId,
          'content': content,
          'files': files ?? [],
        },
      );
      return true;
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Fetches channels from an organization
  /// Org ID must not be null
  @override
  Future<List> fetchChannelsInOrg(String orgId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.get(
        '$channelsBaseUrl/v1/$orgId/channels/',
        headers: headers,
      );
      _log.i(res);
      return res['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Creates channels into the organization
  /// All are
  @override
  Future<bool> createChannels(String name, String owner, String email,
      String orgId, String description, bool private) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.post(
        '$channelsBaseUrl/v1/$orgId/channels/',
        body: {
          'name': name,
          'owner': owner,
          'description': description,
          'private': private,
        },
        headers: headers,
      );
      _log.i(res.toString());
      return true;
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Fetches the details of a channel
  @override
  Future fetchChannelDetails(String orgId, String channelId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final response = await _service.get(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/',
        headers: headers,
      );
      return response['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Fetches channel messages
  @override
  Future<List<ChannelMembermodel>> getChannelMembers(
      String id, String orgId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.get(
          '$channelsBaseUrl/v1/$orgId/channels/$id/members/',
          headers: headers);
      _log.i(res);
      return (res?.data as List)
          .map((e) => ChannelMembermodel.fromJson(e))
          .toList();
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  // /// Fetches a list of  all channels in that organization
  // @override
  // Future<List?> allChannelsList(String currentOrgId) async {
  //   try {
  //     final res = await _service.get(
  //         '$channelsBaseUrl/v1/$currentOrgId/channels/',
  //         headers: {'Authorization': 'Bearer $token'});
  //     _log.i(res['data']);
  //     return res['data'];
  //   } on Failure catch (e) {
  //     _log.w(e.toString());
  //     rethrow;
  //   } catch (e) {
  //     _log.w(e.toString());
  //     throw UnknownFailure(errorMessage: e.toString());
  //   }
  // }

  /// Fetches a list of channels that a user is, in that organization
  @override
  Future joinedChannelsList(String currentOrgId, String currentUserId) async {
    try {
      final res = await _service.get(
          '$channelsBaseUrl/api/v1/$currentOrgId/channels/users/$currentUserId/',
          headers: {'Authorization': 'Bearer $token'});
      _log.i(res);
      return ChannelsSearch.fromJson(res);
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  /// Fetches a list of members in that organization
  @override
  Future fetchListOfMembers(String currentOrgId, String channelId) async {
    try {
      final res = await _service.get(
          '$channelsBaseUrl/vi/$currentOrgId/channels/$channelId/members/',
          headers: {'Authorization': 'Bearer $token'});
      _log.i(res);
      return NewUser.fromJson(res['data']);
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<PinnedMessage>> getChannelPinnedMessages(
      String orgId, String channelId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.get(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/search_messages/',
        data: {"pinned": true},
        headers: headers,
      );
      return (res as List).map((e) => PinnedMessage.fromJson(e)).toList();
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> changeChannelMessagePinnedState(String orgId, String channelId,
      String messageId, String userId, bool pinned) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.patch(
        '$channelsBaseUrl/v1/$orgId/messages/$messageId/',
        where: {"user_id": userId, "channel_id": channelId},
        body: {"pinned": true},
        headers: headers,
      );
      return res['pinned'] == pinned;
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future deleteChannelMessage(
      String orgId, String channelId, String messageId, String userId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.delete(
        '$channelsBaseUrl/v1/$orgId/messages/$messageId/',
        where: {"user_id": userId, "channel_id": channelId},
        body: {"pinned": true},
        headers: headers,
      );
      return res['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> deleteChannel(String orgId, String channelId) async {
    try {
      final headers = {'Authorization': 'Bearer $token'};
      final res = await _service.delete(
        '$channelsBaseUrl/v1/$orgId/channels/$channelId/',
        headers: headers,
      );
      return res['data'];
    } on Failure catch (e) {
      _log.w(e.toString());
      rethrow;
    }
  }

  Map get headers => {'Authorization': 'Bearer $token'};

  String? get token =>
      _storageService.getString(StorageKeys.currentSessionToken);
}
