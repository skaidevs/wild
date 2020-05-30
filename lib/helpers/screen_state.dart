import 'package:audio_service/audio_service.dart';
import 'package:wildstream/helpers/downloads.dart';

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;
  final List<Download> downloadDao;

  ScreenState({
    this.queue,
    this.mediaItem,
    this.playbackState,
    this.downloadDao,
  });
}
