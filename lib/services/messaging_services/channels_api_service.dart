import 'dart:async';
import 'package:stacked_services/stacked_services.dart';
import 'package:zurichat/api_request/channels_api/channels_api.dart';
import 'package:zurichat/models/channel_members.dart';
import 'package:zurichat/models/channel_model.dart';
import 'package:zurichat/models/pinned_message_model.dart';
import 'package:zurichat/utilities/enums.dart';
import 'package:zurichat/utilities/failures.dart';

import '../../app/app.locator.dart';
import '../../app/app.logger.dart';
import '../app_services/local_storage_services.dart';
import '../in_review/user_service.dart';
import '../../utilities/constants/storage_keys.dart';

class ChannelsApiService {
  final log = getLogger('ChannelsApiService');
  final _api = ChannelsRepo();
  final storageService = locator<SharedPreferenceLocalStorage>();
  final _userService = locator<UserService>();
  final _snackbarService = locator<SnackbarService>();

  StreamController<String> controller = StreamController.broadcast();

  // Your functions for api calls can go in here
  // https://channels.zuri.chat/api/v1/61459d8e62688da5302acdb1/channels/
  //TODo - fix

  Future<List> getActiveChannels() async {
    final orgId = _userService.currentOrgId;
    log.w('asc: $orgId');

    var joinedChannels = [];

    try {
      final res = await _api.fetchChannelsInOrg(orgId);
      joinedChannels = res;
      log.i(joinedChannels);
    } on Exception catch (e) {
      log.e(e.toString());
      return [];
    }

    return joinedChannels;
  }

  Future<String> getChannelSocketId(String channelId) async {
    final orgId = _userService.currentOrgId;

    var socketName = '';

    try {
      final res = await _api.getChannelSocketId(channelId, orgId);
      socketName = res ?? '';
      log.i(socketName);
    } on Exception catch (e) {
      log.e(e.toString());
      return 'error';
    }

    return socketName;
  }

  Future<Map?> joinChannel(String channelId) async {
    await storageService.clearData(StorageKeys.currentChannelId);
    final userId = _userService.userId;
    final orgId = _userService.currentOrgId;

    try {
      final res = await _api.joinChannel(channelId, userId, orgId);
      await storageService.setString(StorageKeys.currentChannelId, channelId);
      log.i(res);

      //  log.i(channelMessages);
      return res;
    } catch (e) {
      log.e(e.toString());
      return {};
    }
  }

  Future<String> getChanelCreator(String channelId) async {
    final orgId = _userService.currentOrgId;
    try {
      final res = await _api.fetchChannelDetails(orgId, channelId);
      return res['owner'];
    } catch (e) {
      log.e(e.toString());
      return e.toString();
    }
  }

  Future<Map?> addChannelMember(String channelId, memberId) async {
    await storageService.clearData(StorageKeys.currentChannelId);
    final orgId = _userService.currentOrgId;

    try {
      final res = await _api.addMemberToChannel(channelId, orgId, memberId);
      await storageService.setString(StorageKeys.currentChannelId, channelId);
      log.i(res);
      return res ?? {};
    } on Exception catch (e) {
      log.e(e.toString());
      return {};
    }
  }

  Future<List> getChannelMessages(String channelId) async {
    final orgId = _userService.currentOrgId;

    List channelMessages;

    try {
      final res = await _api.getChannelMessages(channelId, orgId);
      channelMessages = res ?? [];
      log.i(channelMessages);
    } on Exception catch (e) {
      log.e(e.toString());
      return [];
    }
    return channelMessages;
  }

  Future<List<PinnedMessage>> getChannelPinnedMessages(String channelId) async {
    final orgId = _userService.currentOrgId;
    List<PinnedMessage> pinnedMessages;

    try {
      final res = await _api.getChannelPinnedMessages(orgId, channelId);
      pinnedMessages = res;
      log.i(pinnedMessages);
    } on Exception catch (e) {
      log.e(e.toString());
      return [];
    }

    return pinnedMessages;
  }

  Future<bool> changeChannelMessagePinnedState(
      String channelId, String messageId, String userId, bool pinned) async {
    final orgId = _userService.currentOrgId;
    bool successful;

    try {
      final res = await _api.changeChannelMessagePinnedState(
          orgId, channelId, messageId, userId, pinned);

      successful = res;

      log.i(successful);
    } on Exception catch (e) {
      log.e(e.toString());
      return false;
    }

    return successful;
  }

  Future sendChannelMessages(String channelId, String userId, String message,
      [List<String>? media]) async {
    final userId = _userService.userId;
    final orgId = _userService.currentOrgId;

    dynamic channelMessage;

    try {
      final res = await _api.sendChannelMessages(
          channelId, userId, orgId, message, media);
      channelMessage = res ?? {};

      log.i(channelMessage);
    } on Exception catch (e) {
      log.e(e.toString());
      return [];
    }

    return channelMessage;
  }

  Future<bool> createChannels({
    required String name,
    required String description,
    required bool private,
    String? email,
    String? id,
  }) async {
    final owner = email ?? _userService.userEmail;
    final orgId = id ?? _userService.currentOrgId;

    try {
      final res = await _api.createChannels(
          name, owner, email!, orgId, description, private);

      log.i(res.toString());

      if (res) {
        controller.sink.add('created channel');
        return true;
      }
    } catch (e) {
      log.e(e.toString());
    }

    return false;
  }

  Future<void> addReplyToMessage(String? messageId, String orgId,
      String channelId, String userId, String? content, files) async {
    log.i('CHANNEL ID is $channelId');
    try {
      final res = await _api.addReplyToMessage(
          messageId, orgId, channelId, userId, content, files ?? []);
      controller.sink.add('Reply sent successfully');
      log.i('RESULT is $res');
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    }
  }

  Future<List> getRepliesToMessages(String orgId, String messageId) async {
    try {
      final res = await _api.getRepliesToMessages(orgId, messageId);
      return res;
    } on Failure catch (e) {
      log.w(e.toString());
      rethrow;
    }
  }

  Future deleteChannelMessage(
      String orgId, String channelId, String messageId, String userId) async {
    try {
      await _api.deleteChannelMessage(orgId, channelId, messageId, userId);
      controller.sink.add('Message Deleted');
      _snackbarService.showCustomSnackBar(
          duration: const Duration(milliseconds: 1500),
          variant: SnackbarType.success,
          message: 'Message deleted successfully');
      return true;
    } catch (e) {
      log.e(e.toString());
      return false;
    }
  }

  Future<bool> deleteChannel(String orgId, String channelId) async {
    try {
      await _api.deleteChannel(orgId, channelId);
      controller.sink.add('Channel Deleted');
      return true;
    } catch (e) {
      log.e(e.toString());
      return false;
    }
  }

  Future<ChannelModel?> getChannelPage(id) async {
    String orgId = _userService.currentOrgId;

    try {
      final response = await _api.fetchChannelDetails(orgId, id);
      return ChannelModel.fromJson(response);
    } on Exception catch (e) {
      log.e("Channels page Exception $e");
    } catch (e) {
      log.e(e);
    }
  }

  Future<List<ChannelMembermodel>?> getChannelMembers(id) async {
    String orgId = _userService.currentOrgId;
    try {
      final res = await _api.getChannelMembers(id, orgId);
      return res;
    } on Exception catch (e) {
      log.e("Channels member EXception $e");
    } catch (e) {
      log.e(e);
    }
  }

  Future<void>? dispose() {
    controller.close();
  }

  String? get token =>
      storageService.getString(StorageKeys.currentSessionToken);
}
