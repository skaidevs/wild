import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/models/album_details.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/widgets/commons.dart';

class AlbumDetails extends StatelessWidget {
  static const routeName = '/album_detail';

  @override
  Widget build(BuildContext context) {
    final _notifier = Provider.of<AlbumDetailNotifier>(context);
    final _albumId =
        ModalRoute.of(context).settings.arguments as String; //is the id!
    final _loadedAlbum = Provider.of<AlbumNotifier>(context, listen: false)
        .findAlbumById(code: _albumId);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('${_loadedAlbum.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Image.network(
                  '${_loadedAlbum.albumArt.crop.crop200}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: Center(
          child: FutureBuilder<List<Songs>>(
            future: _notifier.loadAlumsDetailList(code: _loadedAlbum.code),
            builder: (
              context,
              snapshot,
            ) {
              print('DATA HAS? ${snapshot?.data}');
              if (snapshot.hasData) {
                return ListView.builder(
                  padding: const EdgeInsets.all(2.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _notifier.detailAlbumList.length,
                  itemBuilder: (context, index) => ListTile(
                    //key: PageStorageKey(_notifier.detailAlbumList[index].code),
                    leading: Row(
                      children: <Widget>[
                        // Text('${index + 1}.'),
                        GFAvatar(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                          shape: GFAvatarShape.standard,
                          size: 30.0,
                          backgroundImage: NetworkImage(_notifier
                              .detailAlbumList[index].songArt.crops.crop100),
                        ),
                      ],
                    ),
                    title: Text(
                      '${_notifier.detailAlbumList[index].name}',
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
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
    /*Scaffold(
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
          Center(
            child: FutureBuilder<AlbumSong>(
              future:
                  _albumDetails.loadAlumsDetailList(code: _loadedAlbum.code),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasData) {
                  return ListTile(
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
                  );
                  */ /*SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) => Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                        ),
                        child:
                      ),
                    ),
                  ));*/ /*
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ),
          */ /*SliverList(
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
          ))*/ /*
        ],
      ),
    );*/
  }
}
