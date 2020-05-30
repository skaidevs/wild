import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/models/search.dart';
import 'package:wildstream/providers/search.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: FloatAppBar(),
      /*AppBar(
        title: Text('Search Wildstream'),
       actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.search,
                ),
                onPressed: () async {
                  final Data result = await showSearch<Data>(
                    context: context,
                    delegate: SongSearch(),
                  );
                  kFlutterToast(
                    context: context,
                    msg: '${result?.name}',
                  );
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result?.name),
                    ),
                  );
                  print("RESULT ");
                }),
          ),
        ],
      )*/
      body: Container(
        padding: Platform.isIOS
            ? const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                116.0,
              )
            : const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                116.0,
              ),
        child: Consumer<SearchNotifier>(builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return Center(child: LoadingInfo());
          }
          return notifier.searchSongList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FaIcon(
                        FontAwesomeIcons.search,
                        size: 40.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'SEARCH',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(2.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: notifier.searchSongList.length,
                  itemBuilder: (context, index) => _buildSearchItem(
                    searchSong: notifier.searchSongList[index],
                    onTap: () {
                      playMediaFromButtonPressed(
                        mediaList: notifier.mediaList,
                        playFromId: notifier.mediaList[index].id,
                      );
                      print('playing from Search id....');
                    },
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildSearchItem({
    Function onTap,
    Data searchSong,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  GFAvatar(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    shape: GFAvatarShape.standard,
                    size: 38.0,
                    backgroundImage: NetworkImage(
                      searchSong.songArt.crops.crop100,
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${searchSong.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${searchSong.artistsToString}',
                          style: kTextStyle(
                            fontSize: 12.0,
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
            if (searchSong.songFile.songUrl == searchSong.songFile.songUrl)
              kMediaIndicator()
            else
              Icon(
                Icons.more_horiz,
                color: kColorWSGreen,
              ),
            /*StreamBuilder<ScreenState>(
              stream: screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
                final _mediaId = screenState?.mediaItem?.id;
                if (_mediaId == searchSong.songFile.songUrl) {
                  return kMediaIndicator();
                } else {
                  return Icon(
                    Icons.more_horiz,
                    color: kColorWSGreen,
                  );
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }
}

class FloatAppBar extends StatelessWidget with PreferredSizeWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _searchNotifier = Provider.of<SearchNotifier>(
      context,
      listen: false,
    );
    return Stack(
      children: <Widget>[
        Positioned(
          top: preferredSize.height - 14.0,
          right: 15,
          left: 15,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(
                6.0,
              ),
            ),
            // color: kColorWhite,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    style: kTextStyle(
                        color: kColorWSGreen, fontWeight: FontWeight.bold),
                    /*onChanged: (String value) {
                    print("Text field: $value");
                  },*/
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String searchValue) async {
                      print("search");
                      if (searchValue == null || searchValue.length == 0) {
                        return print('TEXT FIELD IS EMPTY');
                      }
                      await _searchNotifier.loadSearchedSongs(
                        query: searchValue.trim(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search WildStream',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FaIcon(
                    FontAwesomeIcons.search,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
