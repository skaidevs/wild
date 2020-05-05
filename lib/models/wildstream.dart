import 'package:flutter/cupertino.dart';

class WildStream with ChangeNotifier {
  final String app;
  final String token;

  WildStream({this.app, this.token});

  factory WildStream.fromJson(Map<String, dynamic> parsedJson) {
    return WildStream(
      app: parsedJson['app'],
      token: parsedJson['token'],
    );
  }
}
