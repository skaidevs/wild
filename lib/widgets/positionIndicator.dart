import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:wildstream/widgets/commons.dart';

List<MediaItem> _queue = [
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/3/9/imported-jy9orzxchz2q7ztywtdj.mp3",
    album: "Location..",
    title: "Location",
    artist: "Dave (feat. Burna Boy)",
    duration: 573980,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/M0RFK2rW5KY.png",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/10/2/imported-a0ntuflslqeab.mp3",
    album: "Koto Aye (Vol.2)..",
    title: "Koto Aye (Vol.2)",
    artist: "Davolee, Mr Bee, Mohbad, Tsalt",
    duration: 285690,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/ClyAcxYF8om3e.jpg",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/6/21/imported-riszoibwx2q1mfqe.mp3",
    album: "Ello Baby..",
    title: "Ello Baby",
    artist: "Tiwa Savage, Young John, Kizz Daniel",
    duration: 573980,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/mr0Yugxihk.jpg",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/11/29/imported-b73xojzkvexxnce.mp3",
    album: "Vibration..",
    title: "Vibration",
    artist: "Fireboy DML",
    duration: 285690,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/LPbfhZ6KHX.jpg",
  ),
];

class PositionIndicator extends StatelessWidget {
  final BehaviorSubject<double> dragPositionSubject;
  final MediaItem mediaItem;
  final PlaybackState state;

  const PositionIndicator(
      {Key key, this.dragPositionSubject, this.mediaItem, this.state})
      : super(key: key);
  //TODO: Consider changing slider to also react to seekPos as well (to int can't be called on null)

  String _printDuration(Duration duration) {
    //NOTE: Does not account for days or anything greater than days
    // Duration duration = Duration(milliseconds: ms);
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // logger.log();
//      print("Duration $twoDigitMinutes:$twoDigitSeconds");
    if (duration.inHours == 0) return "$twoDigitMinutes:$twoDigitSeconds";
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    double seekPos;

    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data ?? state.currentPosition.toDouble();
        double duration = mediaItem?.duration?.toDouble();
        return Column(
          children: [
            if (duration != null)
              Slider(
                activeColor: Theme.of(context).accentColor,
                inactiveColor: Theme.of(context).bottomAppBarColor,
                min: 0.0,
                max: duration,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(value.toInt());
                  // Due to a delay in platform channel communication, there is
                  // a brief moment after releasing the Slider thumb before the
                  // new position is broadcast from the platform side. This
                  // hack is to hold onto seekPos until the next state update
                  // comes through.
                  // TODO: Improve this code.
                  seekPos = value;
                  dragPositionSubject.add(null);
                },
              ),
            Text(
              "${(state.currentPosition / 1000).toStringAsFixed(3)}",
              style: TextStyle(
                color: kColorWhite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 20, 0),
              child: Container(
                transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                child: Row(children: <Widget>[
                  Text(
                    //Shows duration of slider or actual playback state duration
                    "${_printDuration(
                      Duration(
                          milliseconds: dragPositionSubject.value != null
                              ? dragPositionSubject.value.toInt()
                              : state.currentPosition),
                    )}",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        color: kColorWhite),
                  ),

                  Spacer(), //
                  Text(
                    // Value below was originally mediaItem?.duration? (check if this causes errors)
                    //Shows duration of slider or actual playback state duration - current playBack state position
                    mediaItem == null
                        ? "-00:00"
                        : "-${_printDuration(
                            dragPositionSubject.value != null
                                ? Duration(milliseconds: mediaItem?.duration) -
                                    Duration(
                                      milliseconds:
                                          dragPositionSubject.value.toInt(),
                                    )
                                : Duration(milliseconds: mediaItem?.duration) -
                                    Duration(
                                        milliseconds: state.currentPosition),
                          )}",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        color: kColorWhite),
                  ), // use Spacer
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}
