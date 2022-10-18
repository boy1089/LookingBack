import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:math';

//TODO : put global variables to StateProvider - date/month/year, setting, current page

class DayPage extends StatefulWidget {
  // SensorDataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(
      // this.dataReader,
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;

  List response = [];
  int dataIndexInDataReader = 0;
  int indexOfDate2 = 0;
  dynamic photoResponseModified = [];
  dynamic sensorDataModified = [];
  dynamic googlePhotoDataForPlot = [[]];
  dynamic sensorDataForPlot = [[]];
  dynamic d;

  double imageSize = 150;
  double imageLocationFactor = 1.5;
  List<dynamic> googlePhotoLinks = [];
  List<DateTime> datesOfYear =
      getDaysInBetween(DateTime.parse("20220101"), DateTime.now())
          .reversed
          .toList();
  Future readData = Future.delayed(const Duration(seconds: 1));

  Future<List<dynamic>> _fetchData() async {
    await Future.delayed(const Duration(microseconds: 100));
    await updateUi();
    // return dataReader.readFiles();
    return googlePhotoLinks;
  }

  @override
  void initState() {
    super.initState();
    // dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;
    readData = _fetchData();
    updateUi();
    print("DayPage, after initState : ${googlePhotoDataForPlot}");
  }

  @override
  Widget build(BuildContext context) {
    // updateUi();
    var date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    print("date : $date");
    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print("snapshot.data : ${snapshot.data}");

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            body: Column(
              children: [
                SizedBox(
                    height: physicalHeight / 2,
                    width: physicalWidth,
                    child: !snapshot.hasData
                        ? Center(
                            child: SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  strokeWidth: 10,
                                )))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                SizedBox(
                                  width: physicalWidth,
                                  height: physicalHeight / 2,
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          left: physicalWidth / 2 -
                                              kSecondPolarPlotSize / 2,
                                          top: physicalHeight / 4 -
                                              kSecondPolarPlotSize / 2,
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            width: kSecondPolarPlotSize,
                                            height: kSecondPolarPlotSize,
                                            child: PolarSensorDataPlot(
                                                    sensorDataForPlot[0]
                                                                .length ==
                                                            0
                                                        ? dummyData
                                                        : sensorDataForPlot)
                                                .build(context),
                                          ),
                                        ),
                                        Container(
                                            width: kThirdPolarPlotSize,
                                            height: kThirdPolarPlotSize,
                                            child: Align(
                                              alignment: Alignment(
                                                  cos((googlePhotoDataForPlot[0]
                                                                  [0]) /
                                                              24 *
                                                              2 *
                                                              pi -
                                                          pi / 2) *
                                                      imageLocationFactor,
                                                  imageLocationFactor *
                                                      sin((googlePhotoDataForPlot[
                                                                  0][0]) /
                                                              24 *
                                                              2 *
                                                              pi -
                                                          pi / 2)),
                                              child: Image.network(
                                                googlePhotoDataForPlot[2][1],
                                                width: imageSize,
                                                height: imageSize,
                                              ),
                                            )),
                                        Container(
                                            width: kThirdPolarPlotSize,
                                            height: kThirdPolarPlotSize,
                                            child: Align(
                                              alignment: Alignment(
                                                  imageLocationFactor*
                                                      cos((googlePhotoDataForPlot[
                                                                  20][0]) /
                                                              24 *
                                                              2 *
                                                              pi -
                                                          pi / 2),
                                                  imageLocationFactor *
                                                      sin((googlePhotoDataForPlot[
                                                                  20][0]) /
                                                              24 *
                                                              2 *
                                                              pi -
                                                          pi / 2)),
                                              child: Image.network(
                                                googlePhotoDataForPlot[20][1],
                                                width: imageSize,
                                                height: imageSize,
                                              ),
                                            )),
                                        Container(
                                            width: kThirdPolarPlotSize,
                                            height: kThirdPolarPlotSize,
                                            child: Align(
                                              alignment: Alignment(
                                                  imageLocationFactor* cos((googlePhotoDataForPlot
                                                              .last[0]) /
                                                          24 *
                                                          2 *
                                                          pi -
                                                      pi / 2),
                                                  imageLocationFactor* sin((googlePhotoDataForPlot
                                                              .last[0]) /
                                                          24 *
                                                          2 *
                                                          pi -
                                                      pi / 2)),
                                              child: Image.network(
                                                googlePhotoDataForPlot.last[1],
                                                width: imageSize,
                                                height: imageSize,
                                              ),
                                            )),
                                        Positioned(
                                            left: physicalWidth / 2 -
                                                kThirdPolarPlotSize / 2,
                                            top: physicalHeight / 4 -
                                                kThirdPolarPlotSize / 2,
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                width: kThirdPolarPlotSize,
                                                height: kThirdPolarPlotSize,
                                                child: Chart(
                                                  data: ((googlePhotoDataForPlot[
                                                                  0]
                                                              .length ==
                                                          0))
                                                      ? dummyData
                                                      : googlePhotoDataForPlot
                                                          .sublist(0),
                                                  elements: [
                                                    PointElement(
                                                      size: SizeAttr(
                                                          variable: 'dummy',
                                                          values: [7, 8]),
                                                    ),
                                                  ],
                                                  variables: {
                                                    'time': Variable(
                                                      accessor: (List datum) =>
                                                          datum[0] as num,
                                                      scale: LinearScale(
                                                          min: 0,
                                                          max: 24,
                                                          tickCount: 5),
                                                    ),
                                                    'dummy': Variable(
                                                      accessor: (List datum) =>
                                                          datum[2] as num,
                                                    ),
                                                  },
                                                  coord: PolarCoord(),
                                                ))),
                                      ]),
                                ),
                              ])),
                Center(
                  child: SizedBox(
                      width: physicalWidth,
                      height: 50,
                      //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                      child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                              initialItem:
                                  datesOfYear.indexOf(DateTime.parse(date))),
                          // magnification: 1,
                          squeeze: 1.8,
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 0.7,
                          onSelectedItemChanged: (index) => setState(() {
                                context
                                    .read<NavigationIndexProvider>()
                                    .setDate(datesOfYear[index]);

                                updateUi();
                              }),
                          itemExtent: 80,
                          restorationId: "aa",
                          childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) => Center(
                                    child: Text(
                                        DateFormat("yyyyMMdd")
                                            .format(datesOfYear[index]),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54)),
                                  ),
                              childCount: datesOfYear.length))),
                ),
                // Center(
                //     child: SizedBox(
                //         width: physicalWidth,
                //         height: physicalHeight / 4,
                //         child: !snapshot.hasData
                //             ? Center(child: CircularProgressIndicator())
                //             : googlePhotoLinks.isEmpty
                //                 ? const Text('no links')
                //                 : ListView.builder(
                //                     // ListView.builder(
                //
                //                     scrollDirection: Axis.horizontal,
                //                     itemBuilder:
                //                         (BuildContext context, int index) {
                //                       // print(googlePhotoLinks[index]);
                //                       return Image.network(googlePhotoLinks
                //                           .reversed
                //                           .toList()[index]);
                //                     },
                //                     itemCount: googlePhotoLinks.length,
                //                   )))
              ],
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: (() async {
            //     setState(() {});
            //     // updatePhoto();
            //     print(dataManager.summaryOfGooglePhotoData);
            //     print(
            //         "checking contaiments : ${dataManager.summaryOfGooglePhotoData.containsKey(20221001)}");
            //   }),
            // ),
          );
        });
  }

  Future updateUi() async {
    var date2 = DateTime.parse(
        Provider.of<NavigationIndexProvider>(context, listen: false).date);
    bool isGooglePhotoFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv")
        .exists();
    bool isProcessedSensorFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/processedSensorData/${formatDate(date2)}_processedSensor.csv")
        .exists();

    print("isFileExists $isGooglePhotoFileExists");
    // try {
    //   updatePhoto();
    // } catch (e) {
    //   print(e);
    // }
    var a = await updatePhoto();
    setState(() {
      // try {
      //   if (isGooglePhotoFileExists) {
      //     print("opening file");
      //     openFile(
      //         "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv");
      //   } else {
      //     updatePhoto();
      //   }
      // } catch(e){
      //   print(e);
      //   print("error in updateUI for google Photo");
      // }
      if (isProcessedSensorFileExists) {
        openSensorData(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/processedSensorData/${formatDate(date2)}_processedSensor.csv");
      } else {
        updateSensorData();
      }
    });
    print("updateUi");
    setState(() {});
  }

  void openFile(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    print("open file");
    googlePhotoDataForPlot = modifyListForPlot(fields, filterTime: true);
    print("googlePhotoDataForPlot : $googlePhotoDataForPlot");
    googlePhotoLinks = transpose(googlePhotoDataForPlot).elementAt(1);
  }

  Future updatePhoto() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    response =
        await this.googlePhotoDataManager.getPhoto(photoLibraryApiClient, date);
    print("updatePhoto");
    photoResponseModified =
        modifyListForPlot(response, executeTranspose: true, filterTime: true);

    googlePhotoDataForPlot = photoResponseModified;
    print("dataForPlot : $googlePhotoDataForPlot");
    googlePhotoLinks = transpose(googlePhotoDataForPlot).elementAt(1);
    print("googlePhotoLinks : $googlePhotoLinks");
    googlePhotoDataManager.writePhotoResponse(date, response);
    dataManager.updateSummaryOfGooglePhotoData(date, googlePhotoLinks.length);
    return googlePhotoLinks;
  }

  void openSensorData(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    sensorDataForPlot = modifyListForPlot(fields);
    print("sensorDataForPlot : $sensorDataForPlot");
  }

  void updateSensorData() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;

    var sensorData = await this.sensorDataManager.openFile(date);
    sensorDataModified = subsampleList(sensorData, 50);
    sensorDataForPlot = sensorDataModified;
    print("sensorDataForPlot : $googlePhotoDataForPlot");

    sensorDataManager.writeSensorData(date, sensorDataModified);
  }
}
