import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbasesource/core/base/base_exception.dart';
import 'package:flutterbasesource/core/base/base_response.dart';
import 'package:flutterbasesource/core/models/status_response.dart';
import 'package:flutterbasesource/core/models/wifi_info.dart';
import 'package:flutterbasesource/core/router/router.dart';
import 'package:flutterbasesource/core/services/secure_storage_service.dart';
import 'package:flutterbasesource/core/util/utils.dart';
import 'package:flutterbasesource/ui/constants/app_strings.dart';
import 'package:flutterbasesource/ui/constants/app_value.dart';
import 'package:flutterbasesource/ui/widgets/dialog_custom.dart';
import 'package:http/http.dart' as http;

abstract class BaseService {
  String _url(endpoint, baseUrl) => endpoint.startsWith('https')
      ? endpoint
      : '$baseUrl/$endpoint${endpoint.contains('?') ? '' : '/'}';

  Future<dynamic> get(endpoint, {shouldSkipAuth = false}) async {
    var responseJson;
    try {
      //api domain
      String baseUrl = '';
      final http.Response response = await http
          .get(_url(endpoint, baseUrl),
              headers: await _getHeader(shouldSkipAuth))
          .timeout(Duration(seconds: timeout_duration));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(endpoint, {data, shouldSkipAuth = false}) async {
    var responseJson;
    String baseUrl = '';
    try {
      http.Response response;
      if (data != null) {
        var stringWifiInfo =
            await SecureStorage().getCustomString(SecureStorage.WIFI_INFO);
        WifiInfo wifiInfo = WifiInfo.fromJson(json.decode(stringWifiInfo));
        var bodyData;
        if (wifiInfo.toJson() != null) {
          Map wifi = wifiInfo.toJson();
          bodyData = {...wifi, ...data};
        } else {
          bodyData = data;
        }
        //Crashlytics.instance.log(bodyData.toString());
        response =  await http.Client()
            .post(
              _url(endpoint, baseUrl),
              body: json.encode(bodyData),
              headers: await _getHeader(shouldSkipAuth),
            )
            .timeout(Duration(seconds: timeout_duration));
      } else {
        response = await http.Client()
            .post(
              _url(endpoint, baseUrl),
              headers: await _getHeader(shouldSkipAuth),
            )
            .timeout(Duration(seconds: timeout_duration));
      }
      responseJson = await _returnResponse(response);
      //Crashlytics.instance.log(responseJson.toString());
    } on SocketException {
      //Crashlytics.instance.log('No internet connection');
      Navigator.pop(Utils().getContext());
      showMessageDialogIOS(Utils().getContext(),
          description: Utils.getString(
              Utils().getContext(), txt_no_internet_connection), onPress: () => exit(0));
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postMultiPart(endpoint, {data, shouldSkipAuth = false, multipartFile}) async {
    var responseJson;
    String baseUrl = '';
    try {
      var response;
      var uri = Uri.parse(_url(endpoint, baseUrl));
      var request = http.MultipartRequest("POST", uri);
      request.headers["Content-Type"] = 'multipart/form-data';
      if (!shouldSkipAuth) {
        final apiToken = await SecureStorage().apiToken;
        if (apiToken?.isNotEmpty == true) {
          request.headers[HttpHeaders.authorizationHeader] = "Bearer $apiToken";
        }
      }
      request.files.addAll(multipartFile);
      data.forEach((k, v) {
        request.fields[k] = v;
      });
      response = await request.send().timeout(Duration(seconds: timeout_duration));
      responseJson = await _returnResponse(response, responseType: 'multipart');
      //Crashlytics.instance.log(responseJson.toString());
    } on SocketException {
      //Crashlytics.instance.log('No internet connection');
      Navigator.pop(Utils().getContext());
      showMessageDialogIOS(Utils().getContext(),
          description: Utils.getString(
              Utils().getContext(), txt_no_internet_connection), onPress: () => exit(0));
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _getHeader(shouldSkipAuth) async {
    final header = {"Content-Type": "application/json"};
    if (!shouldSkipAuth) {
      final apiToken = await SecureStorage().apiToken;
      if (apiToken?.isNotEmpty == true) {
        header[HttpHeaders.authorizationHeader] = "Bearer $apiToken";
      }
    }
    return header;
  }

  dynamic _returnResponse(var response, {String responseType = 'http.Response'}) async {
    BaseResponse responseJson;
    var responseBody;
    try {
      if(responseType == 'http.Response')
        responseBody = json.decode(response.body.toString());
      else {
        var body = await response.stream.bytesToString();
        responseBody = json.decode(body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    switch (response.statusCode) {
      case 200:
        responseJson = BaseResponse(
            status: StatusResponse(code: 200, message: 'Success'),
            data: responseBody);
        return responseJson;
        break;
      case 400:
        if (responseBody['errorcode'] == '404') {
          showMessageDialogIOS(Utils().getContext(),
              description:
                  Utils.getString(Utils().getContext(), txt_expired_token),
              onPress: () async {
            SecureStorage().removeCustomString(SecureStorage.PROFILE_CUSTOMER);
            SecureStorage().deleteToken();
            Navigator.pushNamedAndRemoveUntil(
                Utils().getContext(), Routers.login, (r) => false);
          });
        } else {
          responseJson = BaseResponse(
            status:
                StatusResponse(code: 400, message: response.body.toString()),
          );
          return responseJson;
        }
        break;
      case 401:
        SecureStorage().removeCustomString(SecureStorage.PROFILE_CUSTOMER);
        SecureStorage().deleteToken();
        Navigator.pushNamedAndRemoveUntil(
            Utils().getContext(), Routers.login, (r) => false);
        break;
      case 403:
        responseJson = BaseResponse(
          status: StatusResponse(code: 403, message: response.body.toString()),
        );
        return responseJson;
      case 500:
      default:
        responseJson = BaseResponse(
          status: StatusResponse(code: 500, message: response.body.toString()),
        );
        return responseJson;
    }
  }
}
