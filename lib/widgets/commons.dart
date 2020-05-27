import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const MaterialColor bg_color = const MaterialColor(
  0xFF0A0A0A,
  const <int, Color>{
    50: const Color(0xFF0A0A0A),
    100: const Color(0xFF0A0A0A),
    200: const Color(0xFF0A0A0A),
    300: const Color(0xFF0A0A0A),
    400: const Color(0xFF0A0A0A),
    500: const Color(0xFF0A0A0A),
    600: const Color(0xFF0A0A0A),
    700: const Color(0xFF0A0A0A),
    800: const Color(0xFF0A0A0A),
    900: const Color(0xFF0A0A0A),
  },
);
const Color kColorWSGreen = Color(0xFF029D75);
const Color kColorWSAltBlack = Color(0XFF1E222A);
const Color kColorWSYellow = Color(0XFFd4860b);

const Color kColorWhite = Colors.white;

Future kFlutterToast({String msg, BuildContext context}) {
  return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Theme.of(context).bottomAppBarColor,
      textColor: kColorWhite,
      fontSize: 16.0);
}

TextStyle kTextStyle({
  double fontSize,
  Color color,
  FontWeight fontWeight,
}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}

FaIcon kMediaIndicator() {
  return FaIcon(
    FontAwesomeIcons.volumeUp,
    color: kColorWSGreen,
  );
}

Expanded kBuildPlayAndShuffleButton({
  Color color,
  Color textColor,
  IconData iconData,
  String text,
  Function onPressed,
}) {
  return Expanded(
    child: Container(
      height: 42,
      child: RaisedButton(
        elevation: 1.0,
        color: color,
        textColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            4.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(iconData),
            SizedBox(
              width: 10.0,
            ),
            Text(
              text,
              style: kTextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    ),
  );
}
