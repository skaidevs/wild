import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/widgets/commons.dart';

class BuildAlbumList extends StatelessWidget {
  final int index;
  final Function onTap;

  const BuildAlbumList({
    Key key,
    this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<AlbumDetailNotifier>(
      context,
      listen: false,
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  Text(
                    '${index + 1}.',
                    style: kTextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: kColorWSGreen,
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${notifier.detailAlbumList[index].name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${notifier.detailAlbumList[index].artistsToString}',
                          style: kTextStyle(
                            fontSize: 14.0,
                            color: kColorWSGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            StreamBuilder<ScreenState>(
              stream: screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
                MediaItem _mediaItem = screenState?.mediaItem;
                if (_mediaItem?.id == notifier.mediaList[index].id) {
                  return kMediaIndicator();
                } else {
                  return IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_horiz,
                      color: kColorWSGreen,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
