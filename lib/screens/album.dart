import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/screens/album_details.dart';
import 'package:wildstream/widgets/build_album_item.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class Album extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _albumNotifier = Provider.of<AlbumNotifier>(context).albumListData;

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 100) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Album'),
      ),
      body: Container(
        padding: Platform.isIOS
            ? const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                140.0,
              )
            : const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                112.0,
              ),
        child: Consumer<AlbumNotifier>(builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return Center(
              child: LoadingInfo(),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 2.2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            shrinkWrap: true,
            itemCount: notifier.albumListData.length,
            itemBuilder: (context, index) {
              return BuildAlbumItem(
                album: notifier.albumListData[index],
                onTap: () => _push(
                  context: context,
                  code: _albumNotifier[index].code,
                  index: index,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _push({
    BuildContext context,
    String code,
    int index,
  }) {
    final _notifier = Provider.of<AlbumDetailNotifier>(
      context,
      listen: false,
    );
    _notifier.loadAlumsDetailList(code: code);
    Navigator.of(context).pushNamed(
      AlbumDetails.routeName,
      arguments: index,
    );
  }
}
