import 'package:zurichat/app/app.locator.dart';
import 'package:zurichat/services/app_services/local_storage_services.dart';
import 'package:zurichat/utilities/constants/storage_keys.dart';

mixin RepoMixin {
  final _storageService = locator<SharedPreferenceLocalStorage>();

  Map<String, String> get headers => {'Authorization': 'Bearer $token'};

  String? get token =>
      _storageService.getString(StorageKeys.currentSessionToken);
}
