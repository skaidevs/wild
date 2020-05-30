import 'package:audio_service/audio_service.dart';
import 'package:moor/moor.dart' as v;
import 'package:wildstream/helpers/downloads_database.dart';

void insertDownloadedMediaItems({
  MediaItem mediaItem,
  DownloadDao downloadDao,
}) async {
  //TODO: download to file before inserting to DB
  final _downloaded = DownloadsCompanion(
      mediaCode: v.Value(mediaItem.extras['code']),
      mediaIdUri: v.Value(mediaItem.id),
      mediaArtUri: v.Value(mediaItem.artUri),
      mediaTitle: v.Value(mediaItem.title),
      mediaAlbum: v.Value(mediaItem.title),
      mediaArtist: v.Value(mediaItem.artist),
      mediaDuration: v.Value(mediaItem.duration));
  await downloadDao.insertDownload(_downloaded);
  print('ADDED ${mediaItem.extras['code']} ||');
}
