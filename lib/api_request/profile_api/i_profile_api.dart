abstract class IProfileRepo {
  ///This gets the user presence.
  ///returns true if the user is and false if the user is away
  Future<bool> getUserPresence();

  ///This set the user presence to the opposite
  Future<bool> setUserPresence();

  ///This fetches the status and tag it return
  ///the `status` and `tag` as map keys
  Future<Map> fetchStatus();

  ///Pass in the required parameters to set the user data
  Future<bool> setStatus(String tagIcon, String statusText, String expiryTime);
}
