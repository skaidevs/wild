import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoadingInfo extends StatefulWidget {
  final Stream<bool> _isLoading;
  LoadingInfo(this._isLoading);

  @override
  _LoadingInfoState createState() => _LoadingInfoState();
}

class _LoadingInfoState extends State<LoadingInfo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget._isLoading,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data) {
            _controller.forward().then(
                  (_) => _controller.reverse(),
                );
            return FadeTransition(
              opacity: Tween(
                begin: .5,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeIn,
                ),
              ),
              child: Icon(
                FontAwesomeIcons.hackerNewsSquare,
                size: 30.0,
              ),
            );
          }
          return Container();
        });
  }
}
