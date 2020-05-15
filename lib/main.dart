import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/providers/bottom_navigator.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/providers/recorded_stream_download.dart';
import 'package:wildstream/screens/wildstream_home_page.dart';
import 'package:wildstream/widgets/commons.dart';

void main() => runApp(WildStreamApp());

class WildStreamApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final newTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: kColorWhite,
          displayColor: kColorWhite,
        );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SongsNotifier>(
          create: (_) => SongsNotifier(),
          child: WildStreamHomePage(),
        ),
        ChangeNotifierProvider<AudioPlayerTask>(
          create: (_) => AudioPlayerTask(),
        ),
        ChangeNotifierProvider<RecordedStreamDownload>(
          create: (_) => RecordedStreamDownload(),
        ),
        ChangeNotifierProvider<BottomNavigation>(
          create: (_) => BottomNavigation(),
          child: WildStreamApp(),
        ),
      ],
      child: MaterialApp(
        title: 'Wildstrem',
        theme: ThemeData(
            brightness: Brightness.dark,
            accentColorBrightness: Brightness.dark,
            backgroundColor: bg_color,
//            primarySwatch: bg_color,
            primaryColor: Color(0XFF1E222A),
            bottomAppBarColor: Color(0XFF1E222A),
            accentColor: const Color(0XFF029D75),
            hintColor: Colors.white,
            textTheme: newTextTheme),
        debugShowCheckedModeBanner: false,
        home: AudioServiceWidget(
          child: WildStreamHomePage(
            title: 'WildStream',
          ),
        ),
      ),
    );
  }
}
