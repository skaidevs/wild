import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/providers/latest_hot100_throwback.dart';

class RecordedStreamDownload with ChangeNotifier {
  Future<void> streamCount({
    String code,
  }) async {
    return _streamCount(
      songCode: code,
    );
  }

  Future<bool> _streamCount({String songCode}) async {
    final _songCredentialsBody = {
      'song_code': songCode,
    };

    try {
      final response = await http.post(
        Uri.encodeFull('$baseUrl${'stream/$songCode?token='}$token'),
      );

      var extractedData = json.decode(response.body);

      if (response.statusCode != 200) {
        print('ERROR? ${response.body}');

        throw WildStreamError(extractedData['errors']);
      }

      var _streamed = extractedData;
      print('Streamed? ${_streamed.toString()}');
    } catch (error) {
      print("ERROR SEND STREAM COUNT ${error.toString()}");
      return false;
    }

    return true;
  }
}
