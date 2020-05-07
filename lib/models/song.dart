import 'package:flutter/cupertino.dart';

class Song with ChangeNotifier {
  final String name;
  final List<Data> data;
  Song({
    this.name,
    this.data,
  });
  factory Song.fromJson(Map<dynamic, dynamic> parsedJson) {
    var list = parsedJson['data'] as List;
    List<Data> songsData = list.map((i) => Data.fromJson(i)).toList();
    return Song(
      name: parsedJson['name'],
      data: songsData,
    );
  }
}

class Data with ChangeNotifier {
  final String code;
  final String name;
  final String shortUrl;
  final String artistsToString;
  final int duration;
  final String releasedAt;
  final SongFile songFile;
  final SongArt songArt;

  Data({
    this.code,
    this.name,
    this.shortUrl,
    this.artistsToString,
    this.duration,
    this.releasedAt,
    this.songFile,
    this.songArt,
  });

  factory Data.fromJson(Map<dynamic, dynamic> parsedJson) {
    int calculatedDuration(int duration) {
      final _times = 1000;
      final _newDuration = duration * _times;
      return _newDuration;
    }

    return Data(
      code: parsedJson['code'] as String,
      name: parsedJson['name'] as String,
      shortUrl: parsedJson['short_url'] as String,
      artistsToString: parsedJson['artists_to_string'] as String,
      duration: calculatedDuration(parsedJson['duration']),
      releasedAt: parsedJson['released_at'] as String,
      songFile: SongFile.fromJson(parsedJson['file']),
      songArt: SongArt.fromJson(parsedJson['song_art']),
    );
  }
}

class SongFile with ChangeNotifier {
  final String songUrl;
  SongFile({this.songUrl});
  factory SongFile.fromJson(Map<String, dynamic> parsedJson) {
    return SongFile(
      songUrl: parsedJson['url'] as String,
    );
  }
}

class SongArt with ChangeNotifier {
  final String artUrl;
  SongArt({this.artUrl});
  factory SongArt.fromJson(Map<String, dynamic> parsedJson) {
    return SongArt(
      artUrl: parsedJson['url'] as String,
    );
  }
}
