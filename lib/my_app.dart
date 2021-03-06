import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutterbasesource/core/translation/app_translations_delegate.dart';
import 'package:flutterbasesource/ui/constants/app_strings.dart';
import 'package:flutterbasesource/ui/widgets/dialog_custom.dart';
import 'package:launch_review/launch_review.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'core/base/base_response.dart';
import 'core/router/router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/wifi_service.dart';
import 'core/services/working_report_service.dart';
import 'core/translation/application.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final String launchScreen;

  const MyApp({Key key, this.launchScreen}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: Locale('vi'));
    application.onLocaleChanged = onLocaleChange;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    //checkAppUpdate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }

  checkAppUpdate() async {
    final newVersion = NewVersion(
        androidId: txt_app_id, iOSId: 'gsot.timekeeping', context: context);
    final status = await newVersion.getVersionStatus();
    if (status.canUpdate)
      showMessageDialog(navigatorKey.currentState.overlay.context,
          title: 'C???p nh???t ph???n m???m',
          description:
          '???? c?? phi??n b???n m???i ${status.storeVersion}, phi??n b???n c???a b???n l?? ${status.localVersion}, vui l??ng c???p nh???t ph???n m???m ????? ti???p t???c s??? d???ng!',
          buttonText: txt_go_update, onPress: () async {
            LaunchReview.launch(
                androidAppId: txt_app_id, iOSAppId: txt_apple_id);
            exit(0);
          });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkingReportService>(
          create: (context) => WorkingReportService(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
            create: (context) => ConnectivityService()),
        ChangeNotifierProvider<BaseResponse>(
            create: (context) => BaseResponse()),
        ChangeNotifierProvider<WifiService>(
            create: (context) => WifiService()),
      ],
      child: MaterialApp(
        locale: DevicePreview.of(context).locale,
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        initialRoute: widget.launchScreen,
        onGenerateRoute: Routers.generateRoute,
        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale("en", ""),
          const Locale("vi", ""),
        ],
        navigatorKey: navigatorKey,
      ),
    );
  }
}
