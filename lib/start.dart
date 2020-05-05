/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wildstream/main.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    var textColor = Color.fromRGBO(250, 250, 250, 0.95);
    var textStyle = TextStyle(fontFamily: 'PT Sans', color: textColor);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.05, 0.35, 0.95],
            colors: <Color>[
              Color.fromRGBO(30, 30, 30, 1),
              Color.fromRGBO(45, 45, 45, 1),
              Color.fromRGBO(15, 15, 15, 1),
            ],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white54, size: 24),
                  Text(
                    'Music Player',
                    style: textStyle.merge(TextStyle(fontSize: 15)),
                  ),
                  Icon(Icons.more_horiz, color: Colors.white54, size: 24),
                ],
              ),
              SizedBox(height: 100),
              SizedBox(
                width: 320,
                child: Image.asset('images/back.jpeg'),
              ),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration:
                            Duration(seconds: 1), //change time of animation
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation,
                            Widget child) {
                          animation = CurvedAnimation(
                              parent: animation,
                              curve: Curves
                                  .bounceOut); //change anytype of animation
                          return ScaleTransition(
                            alignment:
                                Alignment.bottomLeft, //where page comes from
                            scale: animation,
                            child: child,
                          );
                        },
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation) {
                          return MyHomePage();
                        }),
                  );
                },
                child: Text("Get started"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
