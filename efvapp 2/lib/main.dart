import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:freevideo/home_page.dart';
import 'package:freevideo/container.dart';
import 'package:freevideo/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/screen_util.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('likes');
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(TrackerRouteObserverProvider(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'freevideo',
      navigatorObservers: [TrackerRouteObserverProvider.of(context)],
      builder: (c, w) {
        ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
        // ScreenUtil.instance =
        //     ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
        //       ..init(c);
        if (!kIsWeb) {
          final data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        }
        return w;
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        accentColor: Colors.white,
        primaryColor: Helper.hexToColor('#333333'),
        canvasColor: Helper.hexToColor('#333333'),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ContainerPage(),
    );
  }
}
