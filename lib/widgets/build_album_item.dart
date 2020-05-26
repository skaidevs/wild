import 'package:flutter/material.dart';
import 'package:wildstream/models/album.dart';
import 'package:wildstream/widgets/commons.dart';

class BuildAlbumItem extends StatelessWidget {
  final Data album;
  final Function onTap;

  const BuildAlbumItem({
    Key key,
    this.album,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            6.0,
          ),
          child: GridTile(
            child: Image.network(
              album.albumArt.crop.crop500,
              fit: BoxFit.cover,
            ),
            header: Container(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${album.name}',
                  style: kTextStyle(
                    fontWeight: FontWeight.bold,
                    color: kColorWhite,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: album.artists
                        .map(
                          (artist) => Expanded(
                            child: Text(
                              '${artist.name}',
                              style: kTextStyle(
                                fontWeight: FontWeight.bold,
                                color: kColorWSGreen,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Text(
                    '${album.releasedAt}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
