import 'package:zurichat/models/channel_members.dart';
import 'package:zurichat/models/pinned_message_model.dart';

abstract class IChannelsRepo {
  /// THE SERVICE TO GET THE SOCKET ID FOR A CHANNEL
  /// THIS AIDS THE RTC AS WELL AS GETTING THE MESSAGES
  Future getChannelSocketId(String channelId, String orgId);

  /// THE SERVICE TO GET A CHANNEL PAGE
  /// EITHER CHANNEL DETAILS
  Future fetchChannelDetails(String orgId, String channelId);

  /// THE SERVICE TO JOIN A CHANNEL
  /// THIS CAN BE DONE EITHER BY CALLING THE USER
  /// OR BY MANUALLY ADDING THEM BY USERNAME
  Future<Map> joinChannel(String channelId, String userId, String orgId);

  /// THE SERVICE TO GET ALL CHANNEL MESSAGES FROM THE BACKEND
  /// THIS SERVICE IS SUPPORTED WITH THE RTC METHODS
  Future getChannelMessages(String channelId, String orgId);

  /// THE SERVICE TO SEND MESSAGES INTO THE CHANNEL
  /// THIS CAN EITHER BE A THREAD MESSAGE OR A NORMAL MESSAGE
  /// THIS SERVICE IS SUPPORTED WITH THE RTC METHODS
  Future sendChannelMessages(
      String channelId, String userId, String orgId, String message,
      [List<String>? media]);

  /// THE SERVICE TO FETCH CHANNELS IN AN ORGANIZATION
  /// ALL CHANNELS - BOTH PUBLIC AND PRIVATE ONES
  ///
  /// YOU CAN DO YOUR FILTERING IF YOU WANT TO GET
  /// A SPECIFIC SECTION.
  Future<List> fetchChannelsInOrg(String orgId);

  /// THE SERVICE TO CREATE CHANNELS.
  /// THIS CAN ONLY BE DONE IF THERE ARE PRIVILEDGES
  Future<bool> createChannels(String name, String owner, String email,
      String orgId, String description, bool private);

  /// THE SERVICE TO GET CHANNEL MEMBERS IN REAL TIME
  Future<List<ChannelMembermodel>> getChannelMembers(String id, String orgId);

  // /// THE SERVICE TO FETCH ALL CHANNELS IN AN ORGANIZATION
  // /// THIS UNLOCKS BOTH THE PUBLIC AND PRIVATE ONES
  // /// YOU CAN FILTER TO GET YOUR DESIRED RESULT
  // Future allChannelsList(String currentOrgId);

  Future<List> getRepliesToMessages(String orgId,String messageId);

  Future<bool> addReplyToMessage(String? messageId, String orgId,
      String channelId, String userId, String? content, files);

  Future<void> addMemberToChannel(
      String channelId, String orgId, String userId);

  /// THE SERVICE TO SEARCH FOR CHANNELS JOINED BY A USER
  /// THIS IS A SERVICE HAVE HAS HELPED WITH FILTERING
  Future joinedChannelsList(String currentOrgId, String currentUserId);

  /// THE SERVICE TO FETCH ALL MEMBERS IN AN ORGANIZATIONS
  /// THIS INCLUDES THE ADMINS AND MEMBERS
  Future fetchListOfMembers(String currentOrgId, String channelId);

  /// This method fetches all pinned messages in a channel
  Future<List<PinnedMessage>> getChannelPinnedMessages(
      String orgId, String channelId);

  /// This method changes the _pinned_ status of a channel message
  Future<bool> changeChannelMessagePinnedState(String orgId, String channelId,
      String messageId, String userId, bool pinned);

  Future deleteChannelMessage(
      String orgId, String channelId, String messageId, String userId);

  Future<bool> deleteChannel(String orgId, String channelId);
}
