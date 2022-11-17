import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';

import 'android_notifications_screen.dart';
import '../navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';

import 'package:test_location_2nd/Data/Directories.dart';
import 'package:test_location_2nd/Settings.dart';

enum buttons { googleAccount, Location, Audio, Phone }

class AndroidSettingsScreen extends StatefulWidget {
  // final GoogleAccountManager = googleAccountManager;
  //
  // static var googleAccountManager;
  var googleAccountManager;
  PermissionManager permissionManager;
  AndroidSettingsScreen(
    PermissionManager permissionManager, {
    Key? key,
  })  : permissionManager = permissionManager,
        super(key: key);

  @override
  State<AndroidSettingsScreen> createState() =>
      _AndroidSettingsScreenState(permissionManager);
}

class _AndroidSettingsScreenState extends State<AndroidSettingsScreen> {
  Map selectedDirectories = Map.fromIterable(Directories.directories,
      key: (item) => item, value: (item) => false);

  late PermissionManager permissionManager;
  _AndroidSettingsScreenState(permissionManager) {
    this.permissionManager = permissionManager;
  }

  @override
  Widget build(BuildContext context) {
    print("settingScreen build");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black54),
        ),
        backgroundColor: Colors.white,
      ),
      body: SettingsList(
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            title: Text("Common"),
            tiles: [
              SettingsTile(title: Text("Language"), onPressed: (context) {}),
              SettingsTile(
                title: Text("About"),
                onPressed: (context) {
                  showDialog(
                      context: (context),
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: Container(
                              height: physicalHeight / 5,
                              child: Row(
                                children: [
                                  Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("application"),
                                        Text("version"),
                                        Text("madeby"),
                                        Text("email")
                                      ]),
                                  Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(" : lateD"),
                                        Text(" : 1.0"),
                                        Text(" : Team ?"),
                                        Text(" : boytoboy0108@gmail.com")
                                      ]),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                  child: const Text("close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ]);
                      });
                },
              ),
              SettingsTile(title: Text("Reset"), onPressed: (context) {})
            ],
          ),
          //
          SettingsSection(
            title: Text("Photo"),
            tiles: [
              SettingsTile(
                  title: Text("Directories"),
                  description: Column(
                      children: List<Widget>.generate(
                          Directories.directories.length, (i) {
                    return CheckboxListTile(
                      title: Text(Directories.directories.elementAt(i)),
                      onChanged: (flag) {
                        // selectedDirectories[i] = flag!;
                        // setDirectory();
                        setState(() {});
                      },
                      value: false,
                    );
                  }))),
              SettingsTile(
                  title: Text("Set reference coordinate"),
                  onPressed: (context) {
                    showDialog(
                        context: (context),
                        builder: (BuildContext context) {
                          return AlertDialog(
                              content: Text(
                                  "Current coordinate will be set as reference coordiante, and contents will be updated with it."),
                              actions: [
                                TextButton(
                                    child: const Text("ok"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                TextButton(
                                    child: const Text("close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ]);
                        });
                  }),
              SettingsTile(
                  title: Row(
                      children: [Text("Minimum number of images for graph")]),
                  onPressed: (context) {}),
              SettingsTile(
                  title: Text("Minimum time bewteen images"),
                  onPressed: (context) {})
            ],
          )
        ],
      ),
    );
  }

  // void setDirectory() {
  //   print(selectedDirectories);
  //   print(
  //       Directories.directories.where((i) => selectedDirectories.elementAt(i)));
  // Directories.init()
  // }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}
