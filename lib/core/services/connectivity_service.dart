import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterbasesource/core/enums/connectivity_status.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityStatus status = ConnectivityStatus.Offline;

  ConnectivityStatus get statusValue => status;

  ConnectivityService() {
    Connectivity().checkConnectivity().then((result) {
      _connectivityEvent(result);
    });
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _connectivityEvent(result);
    });
  }

  _connectivityEvent(ConnectivityResult result) async {
    status = _getStatusFromResult(result);
    debugPrint('Connectivity status: $status');
  }

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.WiFi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}
