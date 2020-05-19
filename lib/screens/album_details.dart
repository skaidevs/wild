import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/widgets/commons.dart';

class AlbumDetails extends StatelessWidget {
  static const routeName = '/album_detail';

  @override
  Widget build(BuildContext context) {
    final _albumId =
        ModalRoute.of(context).settings.arguments as String; //is the id!
    final _loadedAlbum = Provider.of<AlbumNotifier>(context, listen: false)
        .findAlbumById(code: _albumId);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            stretch: true,
            //floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${_loadedAlbum.name}'),
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle
              ],
              background: Image.network(
                '${_loadedAlbum.albumArt.crop.crop200}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                ),
                child: ListTile(
                  key: PageStorageKey(_loadedAlbum.code),
                  leading: GFAvatar(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    shape: GFAvatarShape.standard,
                    size: 36.0,
                    backgroundImage:
                        NetworkImage(_loadedAlbum.albumArt.crop.crop200),
                  ),
                  title: Text(
                    '${_loadedAlbum.name}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.more_horiz,
                    color: kColorWSGreen,
                  ),
                  selected: true,
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
