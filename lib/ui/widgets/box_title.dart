import 'package:flutter/cupertino.dart';
import 'package:flutterbasesource/core/util/utils.dart';
import 'package:flutterbasesource/ui/constants/app_colors.dart';
import 'package:flutterbasesource/ui/widgets/tk_text.dart';

Widget boxTitle(BuildContext context, String title) {
  return Container(
    padding:
    EdgeInsets.symmetric(vertical: Utils.resizeHeightUtil(context, 15)),
    child: TKText(
      title,
      tkFont: TKFont.SFProDisplayRegular,
      style: TextStyle(
          fontSize: Utils.resizeWidthUtil(context, 32),
          color: txt_grey_color_v3),
    ),
  );
}