import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterbasesource/ui/views/home.dart';

class Routers {
  static const String home = '/';
  static const String onBoarding = 'onBoarding';
  static const String login = 'login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (context) => route(settings),
        settings: RouteSettings(name: settings.name));
  }

  static route(RouteSettings settings) {
    switch (settings.name) {
      case onBoarding:
        return HomeView();
      case home:
        return HomeView();
      default:
        return;
    }
  }
}
