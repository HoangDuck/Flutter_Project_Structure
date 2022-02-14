import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterbasesource/core/base/base_response.dart';

class SecureStorage {
  static const String API_TOKEN = "apiToken";
  static const String FCM_TOKEN = "fcmToken";
  static const String IS_FIRST_TIME = "is_first_time";
  static const String PROFILE_CUSTOMER = "profile_customer";
  static const String WIFI_INFO = "wifi_info";
  static const String PASSWORD = "password";
  static const String USERNAME = "username";
  static const String CHANGE_PASSWORD = "change_password";

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String> get apiToken async =>
      await _secureStorage.read(key: API_TOKEN);

  Future<BaseResponse> get userProfile async => await _secureStorage
      .read(key: PROFILE_CUSTOMER)
      .then<BaseResponse>((response) => response != null
          ? BaseResponse.fromJson(json.decode(response))
          : null);

  saveApiToken(String token) async {
    await _secureStorage.write(key: API_TOKEN, value: token);
  }

  saveProfileCustomer(BaseResponse baseResponse) async {
    await _secureStorage.write(
        key: PROFILE_CUSTOMER, value: json.encode(baseResponse));
  }

  saveIsFirstTime() async {
    await _secureStorage.write(key: IS_FIRST_TIME, value: 'false');
  }

  Future<bool> isLogin() async {
    final userProfileResult = await _secureStorage.read(key: PROFILE_CUSTOMER);
    return userProfileResult?.isNotEmpty;
  }

  Future<bool> isFirstTime() async {
    final isFirstTime = await _secureStorage.read(key: IS_FIRST_TIME);
    return isFirstTime == null || isFirstTime == 'true';
  }

  deleteAllSS() async {
    // Delete all
    await _secureStorage.deleteAll();
  }

  deleteToken() async {
    await _secureStorage.delete(key: API_TOKEN);
  }

  Future<String> getCustomString(String key) async =>
      await _secureStorage.read(key: key);

  saveCustomString(String key, String data) async {
    await _secureStorage.write(key: key, value: data);
  }

  removeCustomString(String key) async {
    await _secureStorage.delete(key: key);
  }
}
