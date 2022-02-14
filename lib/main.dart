import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as service;
import 'package:flutterbasesource/my_app.dart';
import 'package:provider/provider.dart';
import 'core/components/local_notification.dart';
import 'core/models/wifi_info.dart';
import 'core/router/router.dart';
import 'core/services/secure_storage_service.dart';
import 'core/util/utils.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var launchScreen = await Utils().checkIsFirstTime();
  runApp(DevicePreview(
      enabled: false, builder: (context) => MyApp(launchScreen: launchScreen ?? Routers.onBoarding)));
  await service.SystemChrome.setPreferredOrientations(
      [service.DeviceOrientation.portraitUp]);
  WifiInfo wifiInfo = await Utils().getNetworkInformation();
  SecureStorage()
      .saveCustomString(SecureStorage.WIFI_INFO, json.encode(wifiInfo) ?? '');
  Provider.debugCheckInvalidValueType = null;
  initLocalNotification();
}
