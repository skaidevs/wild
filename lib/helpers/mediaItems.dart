import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/helpers/downloads.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/album_details.dart';
import 'package:wildstream/models/song.dart';

startPlayer() async {
  await AudioService.start(
    backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
    androidNotificationChannelName: 'WildStream',
    notificationColor: 0xFF0A0A0A,
    androidNotificationIcon: 'drawable/ic_notification',
    enableQueue: true,
  );
}

void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

void playFromMediaId({String mediaId}) {
  AudioService.playFromMediaId(mediaId);
  AudioService.play();
}

/// Encapsulate all the different data we're interested in into a single
/// stream so we don't have to nest StreamBuilders.
///
Stream<ScreenState> get screenStateStream =>
    Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
      AudioService.queueStream,
      AudioService.currentMediaItemStream,
      AudioService.playbackStateStream,
      (
        queue,
        mediaItem,
        playbackState,
      ) =>
          ScreenState(
        queue: queue,
        mediaItem: mediaItem,
        playbackState: playbackState,
      ),
    );

Stream<ScreenState> screenStateStreamWithDoa(BuildContext context) {
  final _downloadDao = Provider.of<DownloadDao>(
    context,
    listen: false,
  );
  return Rx.combineLatest2<MediaItem, List<Download>, ScreenState>(
    AudioService.currentMediaItemStream,
    _downloadDao.watchAllDownloads,
    (
      mediaItem,
      dao,
    ) =>
        ScreenState(
      mediaItem: mediaItem,
      downloadDao: dao,
    ),
  );
}

const List<String> songTypes = [
  'latest',
  'hot_100',
  'throw_back',
];

void playMediaFromButtonPressed({
  String playButton,
  String playFromId,
  List<MediaItem> mediaList,
}) async {
  if (playButton == '_playAllFromButton') {
    await AudioService.replaceQueue(mediaList);
    AudioService.play();
    print('Played ALL From Button: ${mediaList.length}');
  } else if (playButton == songTypes[0]) {
    await AudioService.replaceQueue(mediaList).then((_) {
      AudioService.playFromMediaId(playFromId);
      print('Played From Latest: ${mediaList.length}');
    });
  } else if (playButton == songTypes[1]) {
    await AudioService.replaceQueue(mediaList).then((_) {
      AudioService.playFromMediaId(playFromId);
      print('Played From HOT100: ${mediaList.length}');
    });
  } else if (playButton == songTypes[2]) {
    await AudioService.replaceQueue(mediaList).then((_) {
      AudioService.playFromMediaId(playFromId);
      print('Played From THROWBACK: ${mediaList.length}');
    });
  } else if (playButton == 'offlineDownload') {
    await AudioService.replaceQueue(mediaList).then((_) {
      AudioService.playFromMediaId(playFromId);
      print('Played From OFFLINE DOWNLOAD: ${mediaList.length}');
    });
  } else {
    await AudioService.replaceQueue(mediaList).then((_) {
      AudioService.playFromMediaId(playFromId);
    });
    print('Played from ID ELSE BLOCK: ${mediaList.length}');
  }
}

//CONVERTED MEDIA_ITEMS
Future convertAlbumDetailsToMediaItem({
  List<Songs> detailAlbumSongList,
  List<MediaItem> mediaItems,
}) async {
  mediaItems.clear();
  detailAlbumSongList.forEach((media) async {
    mediaItems.add(
      MediaItem(
          id: media.songFile.songUrl,
          album: media.name,
          title: media.name,
          artist: media.artistsToString,
          duration: media.duration,
          artUri: media.songArt.crops.crop500,
          extras: {
            'code': media.code,
          }),
    );
  });
}

Future concertSongsToMediaItem({
  List<Data> songsList,
  List<MediaItem> mediaItems,
}) async {
  songsList.forEach((media) async {
    mediaItems.add(MediaItem(
        id: media.songFile.songUrl,
        album: media.name,
        title: media.name,
        artist: media.artistsToString,
        duration: media.duration,
        artUri: media.songArt.crops.crop500,
        extras: {
          'code': media.code,
        }));
    //print('MediaItems CONVERTED >: ${_mediaList.toList()}');
  });
}

Future concertDownloadToMediaItem({
  List<Download> downloadList,
  List<MediaItem> mediaItems,
}) async {
  downloadList.forEach((media) async {
    mediaItems.add(
      MediaItem(
          id: media.mediaIdUri,
          album: media.mediaTitle,
          title: media.mediaTitle,
          artist: media.mediaArtist,
          duration: media.mediaDuration,
          artUri: media.mediaArtUri,
          extras: {
            'code': media.mediaCode,
          }),
    );
  });
}
