import 'package:flutter/material.dart';
import 'package:flutterbasesource/core/models/wifi_info.dart';

class WifiService with ChangeNotifier {
  WifiInfo _wifi;
  WifiInfo get wifiInfo => _wifi;

  addWifiInfo(WifiInfo data) {
    _wifi = data;
    notifyListeners();
  }
}