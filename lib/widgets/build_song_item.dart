import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:wildstream/widgets/commons.dart';

class BuildSongItem extends StatelessWidget {
  final song;
  final int index;
  final String hot100;

  const BuildSongItem({Key key, this.song, this.index, this.hot100})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: ListTile(
        key: PageStorageKey(0),
        leading: hot100 == 'hot100'
            ? Stack(
                alignment: const Alignment(1.0, 1.0),
                children: <Widget>[
                  GFAvatar(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    shape: GFAvatarShape.standard,
                    size: 38.0,
                    backgroundImage: NetworkImage(song.songArt.artUrl),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        bottomRight: Radius.circular(4.0),
                      ),
                      color: kColorWSYellow,
                    ),
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : GFAvatar(
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ),
                shape: GFAvatarShape.standard,
                size: 38.0,
                backgroundImage: NetworkImage(song.songArt.artUrl),
              ),
        title: Text(
          '${song.name}',
          style: TextStyle(
            color: kColorWhite,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: Text(
            '${song.artistsToString}',
            style: TextStyle(color: kColorWSGreen),
          ),
        ),
        trailing: Icon(
          Icons.more_horiz,
          color: kColorWSGreen,
        ),
        /*StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;
            mediaItem = screenState?.mediaItem;

            if (mediaItem?.id == data.hot100MediaList[index].id) {
              return _mediaIndicator();
            } else {
              return Icon(
                Icons.more_horiz,
                color: kColorWSGreen,
              );
            }
          },
        ),*/
        onTap: () async {
          print("Taped");
//          mediaItem = data.hot100MediaList[index];
//          AudioService.playFromMediaId(mediaItem.id);
        },
        selected: true,
      ),
    );
  }
}
