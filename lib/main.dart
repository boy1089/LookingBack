import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Location/LocationDataManager.dart';
import 'package:lateDiary/Photo/PhotoDataManager.dart';

// import 'package:lateDiary/Sensor/AudioRecorder.dart';
// import 'package:lateDiary/Sensor/SensorRecorder.dart';
import 'package:lateDiary/Util/global.dart';

import 'package:lateDiary/pages/MainPage.dart';
import 'pages/SettingPage.dart';

import 'package:lateDiary/Permissions/PermissionManager.dart';
import 'package:lateDiary/Data/DataManager.dart';
import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

import 'package:lateDiary/Sensor/SensorDataManager.dart';
import 'package:lateDiary/Note/NoteManager.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:lateDiary/Data/Directories.dart';
import 'Settings.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationIndexProvider>(
          create: (context) {
            return NavigationIndexProvider();
          },
        ),
        ChangeNotifierProvider<YearPageStateProvider>(
          create: (context) {
            return YearPageStateProvider();
          },
        ),
        ChangeNotifierProvider<DayPageStateProvider>(
          create: (context) {
            return DayPageStateProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final permissionManager = PermissionManager();
  final sensorDataManager = SensorDataManager();
  final noteManager = NoteManager();

  late final photoDataManager;
  late final locationDataManager;
  //sensorLogger will be initialized after initializing PermissionManager
  late final sensorRecorder;
  late final audioRecorder;
  late final dataManager;

  Future initApp = Future.delayed(const Duration(seconds: 5));

  _MyAppState() {
    // sensorRecorder = SensorRecorder(permissionManager);
    // sensorRecorder.init();
    // audioRecorder = AudioRecorder(permissionManager);
    // audioRecorder.init();

    photoDataManager = PhotoDataManager();
    locationDataManager = LocationDataManager();
    dataManager = DataManager(photoDataManager, locationDataManager);

    initApp = init();
    super.initState();
  }

  Future<int> init() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    isInitializationDone = false;
    await permissionManager.init();
    print("init process, permission manater init done. time elapsed : ${stopwatch.elapsed}");
    await Directories.init(Directories.directories);
    await Settings.init();
    await noteManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    // FlutterNativeSplash.remove();
    await dataManager.init();
    print("init process, time elapsed : ${stopwatch.elapsed}");
    isInitializationDone = true;
    print("init done,executed in ${stopwatch.elapsed}");
    dataManager.executeSlowProcesses();
    FlutterNativeSplash.remove();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    print("start building app..");
    return FutureBuilder(
        future: initApp,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // print("snapshot.hasData? ${snapshot.hasData}, ${snapshot.data}");
          print(snapshot.data);
          return MaterialApp(
            initialRoute: '/daily',
            routes: {
              '/daily': (context) => MainPage(
                    permissionManager,
                    dataManager,
                    sensorDataManager,
                    photoDataManager,
                    noteManager,
                  ),
              '/settings': (context) =>
                  AndroidSettingsScreen(permissionManager),
            },
            useInheritedMediaQuery: true,
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     initialRoute: '/daily',
  //     routes: {
  //       '/daily': (context) => MainPage(
  //             permissionManager,
  //             dataManager,
  //             sensorDataManager,
  //             photoDataManager,
  //             noteManager,
  //           ),
  //       '/settings': (context) =>
  //           AndroidSettingsScreen(permissionManager),
  //     },
  //   );
  // }
}
