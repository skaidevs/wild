import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class AlbumDetails extends StatelessWidget {
  static const routeName = '/album_detail';

  Expanded _buildButton({
    Color color,
    Color textColor,
    IconData iconData,
    String text,
  }) {
    return Expanded(
      child: Container(
        height: 42,
        child: RaisedButton(
          elevation: 1.0,
          color: color,
          textColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              4.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FaIcon(iconData),
              SizedBox(
                width: 10.0,
              ),
              Text(
                text,
                style: kTextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _albumId =
        ModalRoute.of(context).settings.arguments as String; //is the id!
    final _loadedAlbum = Provider.of<AlbumNotifier>(
      context,
      listen: false,
    ).findAlbumById(code: _albumId);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (
          BuildContext context,
          bool innerBoxIsScrolled,
        ) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 150.0,
              excludeHeaderSemantics: true,
              title: Text(
                '${_loadedAlbum.name}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
              floating: true,
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                /*title: Text(
                  '${_loadedAlbum.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),*/
                collapseMode: CollapseMode.pin,
                background: Image.network(
                  '${_loadedAlbum.albumArt.crop.crop500}',
                  fit: BoxFit.cover,
                ),
//                stretchModes: [
//                  StretchMode.zoomBackground,
//                  StretchMode.blurBackground,
//                  StretchMode.fadeTitle
//                ],
              ),
            ),
          ];
        },
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton(
                      color: kColorWSGreen,
                      textColor: kColorWhite,
                      text: 'Play',
                      iconData: FontAwesomeIcons.play),
                  SizedBox(
                    width: 16.0,
                  ),
                  _buildButton(
                      color: kColorWhite,
                      textColor: kColorWSAltBlack,
                      text: 'Shuffle',
                      iconData: FontAwesomeIcons.random),
                ],
              ),
            ),
            Container(
//              padding: EdgeInsets.fromLTRB(
//                0.0,
//                0.0,
//                0.0,
//                112.0,
//              ),
              child: Consumer<AlbumDetailNotifier>(builder: (
                context,
                _notifier,
                _,
              ) {
                if (_notifier.isLoading) {
                  return Center(
                    child: LoadingInfo(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(2.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _notifier.detailAlbumList.length,
                  itemBuilder: (context, index) => Column(
                    children: <Widget>[
                      ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(
                                '${index + 1}.',
                                style: kTextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: kColorWSGreen,
                                ),
                              ),
                            ),
                            Text(
                              '${_notifier.detailAlbumList[index].name}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.more_horiz,
                          color: kColorWSGreen,
                        ),
                        selected: true,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
