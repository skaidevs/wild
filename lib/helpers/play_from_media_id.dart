import 'package:audio_service/audio_service.dart';

void playFromMediaId({String mediaId}) {
  AudioService.playFromMediaId(mediaId);
  AudioService.play();
}
