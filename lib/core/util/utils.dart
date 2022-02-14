import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ip/flutter_ip.dart';
import 'package:flutterbasesource/core/enums/connectivity_status.dart';
import 'package:flutterbasesource/core/models/wifi_info.dart';
import 'package:flutterbasesource/core/router/router.dart';
import 'package:flutterbasesource/core/services/secure_storage_service.dart';
import 'package:flutterbasesource/core/translation/app_translations.dart';
import 'package:flutterbasesource/my_app.dart';
import 'package:get_ip/get_ip.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class Utils {
  static Pattern emailPattern = r'^[a-zA-Z0-9]';
  static const platform = const MethodChannel('flutter.native/helper');

  static bool isInDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Future<WifiInfo> getNetworkInformation() async {
    Connectivity _connectivity = Connectivity();
    ConnectivityResult result;
    String wifiName,
        wifiBSSID,
        external,
        internal,
        identifierForVendor,
        nameForVendor,
        androidId,
        androidName;
    try {
      result = await _connectivity.checkConnectivity();
      if (result != null) {
        if (result == ConnectivityResult.wifi) {
          try {
            if (Platform.isIOS) {
              LocationAuthorizationStatus status =
                  await _connectivity.getLocationServiceAuthorization();
              if (status == LocationAuthorizationStatus.notDetermined) {
                status =
                    await _connectivity.requestLocationServiceAuthorization();
              }
              if (status == LocationAuthorizationStatus.authorizedAlways ||
                  status == LocationAuthorizationStatus.authorizedWhenInUse) {
                wifiName = await _connectivity.getWifiName();
              } else {
                wifiName = await _connectivity.getWifiName();
              }
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } on PlatformException catch (e) {
            print(e.toString());
            wifiName = "Failed to get Wifi Name";
          }

          try {
            if (Platform.isIOS) {
              LocationAuthorizationStatus status =
                  await _connectivity.getLocationServiceAuthorization();
              if (status == LocationAuthorizationStatus.notDetermined) {
                status =
                    await _connectivity.requestLocationServiceAuthorization();
              }
              if (status == LocationAuthorizationStatus.authorizedAlways ||
                  status == LocationAuthorizationStatus.authorizedWhenInUse) {
                wifiBSSID = await _connectivity.getWifiBSSID();
              } else {
                wifiBSSID = await _connectivity.getWifiBSSID();
              }
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } on PlatformException catch (e) {
            print(e.toString());
            wifiBSSID = "Failed to get Wifi BSSID";
          }
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (Platform.isIOS) {
            internal = await FlutterIp.internalIP;
            external = await FlutterIp.externalIP;
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            identifierForVendor = iosInfo.identifierForVendor;
            nameForVendor = iosInfo.name;
          } else {
            internal = await GetIp.ipAddress;
            http.Response response = await http.get('http://api.ipify.org/');
            external = response.body;
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            androidId = androidInfo.androidId;
            androidName = androidInfo.model;
          }

          return WifiInfo(
              identifierForVendor: identifierForVendor,
              nameForVendor: nameForVendor,
              androidId: androidId,
              androidName: androidName,
              wan: external,
              lan: internal,
              wifiSSID: wifiName,
              wifiBSSID: wifiBSSID);
        }
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return null;
  }

  static bool checkNetwork(BuildContext context) {
    var connectionStatus = context.read<ConnectivityStatus>();
    if (connectionStatus == ConnectivityStatus.Offline) {
      return false;
    }
    return true;
  }

  static void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static double resizeWidthSpecialUtil(double width, double value) {
    var screenDesignWidth = 750;
    return (width * value) / screenDesignWidth;
  }

  static double resizeWidthUtil(BuildContext context, double value) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenDesignWidth = 750;
    return (screenWidth * value) / screenDesignWidth;
  }

  static double resizeHeightUtil(BuildContext context, double value) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenDesignHeight = 1344;
    return (screenHeight * value) / screenDesignHeight;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  static String getString(BuildContext context, String value) =>
      AppTranslations.of(context).text(value);

  static dynamic getTitleGenRowOnly(List<dynamic> list) {
    dynamic _list = {};
    list.forEach((item) {
      _list = {
        ..._list,
        ...{
          '${item['Name']['v']}': {
            'key': item['Name']['v'],
            'name': item['VnName']['v'],
          }
        }
      };
    });
    return _list;
  }

  static dynamic getListGenRow(List<dynamic> list, String type) {
    dynamic _list = {};
    list.forEach((item) {
      _list = {
        ..._list,
        ...{
          '${item['Name']['v']}': {
            'key': item['Name']['v'],
            'name': item['VnName']['v'] +
                (item['AllowNull']['v'] == 'False' ? '*' : ''),
            'allowNull': item['AllowNull']['v'] == 'True' || item['AllowNull']['v'] == '' ? true : false,
            'allowEdit': type.contains('add')
                ? (item['AllowEdit']['v'] == 'True' ||
                        item['AllowEdit']['v'] == ''
                    ? true
                    : false)
                : ((item['AllowEdit']['v'] == 'True' ||
                            item['AllowEdit']['v'] == '') &&
                        (item['AllowChange']['v'] == 'True' ||
                            item['AllowChange']['v'] == '')
                    ? true
                    : false),
            'dataType': item['DataType']['v'],
            'show': item['ColumnWidth']['v']
          }
        }
      };
    });
    return _list;
  }

  String convertDoubleToTime(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);
    return '$hourValue:$minuteString';
  }

  String convertTimeToDouble(String time) {
    if (time != '')
      return (int.parse(time.split(":")[0]) +
              int.parse(time.split(":")[1]) / 60.0)
          .toString()
          .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    else
      return '';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  static dynamic encryptHMAC(String data, String secCode) {
    var keyInBytes = utf8.encode(secCode);
    var payloadInBytes = utf8.encode(data);
    var md5Hash = Hmac(md5, keyInBytes);
    return md5Hash.convert(payloadInBytes).toString();
  }

  static String convertJson(dynamic params, String urlReqId, String reqTime,
      {String userName = "noname"}) {
    var jsonString = jsonEncode(params)
        .replaceAll(" ", "")
        .replaceAll("\r", "")
        .replaceAll("\n", "")
        .replaceAll("\"", "'");
    return "$jsonString#$userName#$urlReqId#$reqTime";
  }

  static dynamic encode(dynamic value) {
    return value;
  }

  static dynamic decode(dynamic value) {
    return value;
  }

  static Future encrypt(String value) async {
    var result = await platform.invokeMethod('encryptTripleDes',
        {"key": "smart@things!2020@HRMS***", "string": value});
    return result.toString().replaceAll("\n", "");
  }

  static Future decrypt(String value) async {
    var result = await platform.invokeMethod('decryptTripleDes',
        {"key": "smart@things!2020@HRMS***", "string": value});
    return result.toString().replaceAll("\n", "");
  }

  Future<String> checkIsFirstTime() async {
    await [
      //Permission.location,
      //Permission.camera,
      Permission.microphone,
      Permission.storage
    ].request();
    var apiToken = await SecureStorage().apiToken;
    var userProfile = await SecureStorage().userProfile;
    var onBoarding = await SecureStorage().isFirstTime();
    if (apiToken != null && apiToken.isNotEmpty && userProfile != null) {
      return Routers.home;
    } else if (onBoarding != true)
      return Routers.login;
    return Routers.onBoarding;
  }

  BuildContext getContext() {
    return navigatorKey.currentState.overlay.context;
  }
}
