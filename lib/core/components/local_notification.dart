import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterbasesource/core/util/utils.dart';
import 'package:flutterbasesource/ui/widgets/dialog_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

const NOTIFICATION_TITLE_KEY = "notification_title_key";
const NOTIFICATION_CONTENT_KEY = "notification_content_key";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

initLocalNotification() {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('app_icon_local_notification');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: _onSelectNotification);
}

Future _onSelectNotification(String value) async {
  showTimekeepingDialog();
}

showTimekeepingDialog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String title = prefs.getString(NOTIFICATION_TITLE_KEY);
  String content = prefs.getString(NOTIFICATION_CONTENT_KEY);
  if (title != null && content != null) {
    showMessageDialogIOS(Utils().getContext(),
        title: title, description: content);
    await prefs.remove(NOTIFICATION_TITLE_KEY);
    await prefs.remove(NOTIFICATION_CONTENT_KEY);
  }
}

Future<void> showNotification(String title, String content) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(NOTIFICATION_TITLE_KEY, title);
  prefs.setString(NOTIFICATION_CONTENT_KEY, content);
  await flutterLocalNotificationsPlugin.show(
      0, title, content ?? null, platformChannelSpecifics);
}

Future<void> showDailyRemindTimekeeping(
    int id, Time time, String title, String content) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.showDailyAtTime(
      id, title, content, time, platformChannelSpecifics);
}

Future<void> scheduleNotification(
    int id, DateTime time, String title, String content) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description');
  var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(sound: 'slow_spring_board.aiff');
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
      id, title, content, time, platformChannelSpecifics);
}
