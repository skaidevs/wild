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
    final _notifier = Provider.of<AlbumDetailNotifier>(
      context,
      listen: false,
    );
    int _albumIndex =
        ModalRoute.of(context).settings.arguments as int; //is the id!
    final _albumNotifier = Provider.of<AlbumNotifier>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_albumNotifier.albumListData[_albumIndex].name}',
          style: kTextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(
              12.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      6.0,
                    ),
                    child: Image.network(
                      '${_albumNotifier.albumListData[_albumIndex].albumArt.crop.crop500}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children:
                              _albumNotifier.albumListData[_albumIndex].artists
                                  .map(
                                    (artist) => Text(
                                      '${artist.name}',
                                      style: kTextStyle(
                                        fontSize: 22.0,
                                        color: kColorWSGreen,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                          ),
                          child: Text(
                            '${_notifier.shotUrl == null ? 'https://wstr.am' : _notifier.shotUrl}',
                            style: kTextStyle(
                              color: kColorWSYellow,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                              '${_albumNotifier.albumListData[_albumIndex].releasedAt}'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 13.0,
              right: 13.0,
              bottom: 10.0,
            ),
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
            child:
                Consumer<AlbumDetailNotifier>(builder: (context, _notifier, _) {
              if (_notifier.isLoading) {
                return Center(
                  child: LoadingInfo(),
                );
              }

              return ListView.builder(
                  //padding: const EdgeInsets.all(2.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _notifier.detailAlbumList.length,
                  itemBuilder: (context, index) {
                    index = index;
                    return ListTile(
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
                    );
                  });
            }),
          ),
        ],
      ),
    );
  }

  Widget listItem(Color color, String title) => Container(
        height: 100.0,
        color: color,
        child: Center(
          child: Text(
            "$title",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
