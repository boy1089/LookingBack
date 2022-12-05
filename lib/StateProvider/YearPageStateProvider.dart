import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';
import 'package:lateDiary/Data/summary_model.dart';

class YearPageStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  int year = DateTime.now().year;
  int index = 0;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager);

  dynamic data;
  List<String> availableDates = [];
  int maxOfSummary = 0;

  void update(dataManager) {
    this.dataManager = dataManager;
    updateData();
    notifyListeners();
  }

  void setAvailableDates(int year) {
    // availableDates = dataManager.summaryOfPhotoData.keys.where((element) {
    //   return element.substring(0, 4) == year.toString();
    // }).toList();

    availableDates = dataManager.summaryModel.dates.where((element) {
      return element.substring(0, 4) == year.toString();
    }).toList();
    print(availableDates);
    availableDates.sort();
  }

  void updateData() {
    setAvailableDates(year);

    data = List.generate(1, (index) {
      return [
        0,
        1,
        10,
        0.01,
      ];
    });

    if (availableDates.length == 0) return data;

    int weekdayOfJan01 = DateTime(year).weekday;
    int offsetToMakeWeekendOutward = -2;

    //generate data for graph plot
    data = List.generate(availableDates.length, (index) {
      String date = availableDates[index];

      int days = int.parse(DateFormat("D").format(DateTime.parse(date))) +
          weekdayOfJan01 +
          offsetToMakeWeekendOutward;
      // int value = dataManager.summaryOfPhotoData[date]! > 200
      int count = dataManager.summaryModel.counts![date].data
          .elementAt(imagesColumn.count.index - 1);
      count = count > 200 ? 200 : count;

      double distance = 4;

      double distance_temp = dataManager.summaryModel.locations![date].data
          .elementAt(locationsColumn.location.index - 1);

      if (distance_temp != null) distance = floorDistance(distance_temp);

      return [
        (days / 7).floor(),
        days % 7,
        count,
        distance,
      ];
    });

    // code to filter the data with small amount of images.
    // List<List<dynamic>> temp = [];
    // for(int i = 0; i < data.length; i++){
    //   if(data[i][2]>10) temp.add(data[i]);
    // }
    // data = temp;

    // List<List<dynamic>> temp = [];
    // for(int i = 0; i < data.length; i++){
    //   if(data[i][3]==0) temp.add(data[i]);
    // }
    // data = temp;

    List<int> dummy3 = List<int>.generate(transpose(data)[0].length,
        (index) => int.parse(transpose(data)[2][index].toString()));
    maxOfSummary = dummy3.reduce(max);
    print("year page, dummy3 : $maxOfSummary");

    // notifyListeners();
  }

  void setBottomNavigationBarShown(bool isBottomNavigationBarShown) {
    this.isBottomNavigationBarShown = isBottomNavigationBarShown;
    print("isBottomNavigationBarShown : $isBottomNavigationBarShown");
    notifyListeners();
  }

  void setLastNavigationIndex(int index) {
    lastNavigationIndex = index;
  }

  void setDate(DateTime date) {
    this.date = formatDate(date);
    print("date : ${this.date}");
  }

  void setZoomInRotationAngle(angle) {
    // print("provider set zoomInAngle to $angle");
    zoomInAngle = angle;
    notifyListeners();
  }

  void setZoomInState(isZoomIn) {
    print("provider set isZoomIn to $isZoomIn");
    this.isZoomIn = isZoomIn;
    notifyListeners();
  }

  void setYear(int year, {bool notify: false}) {
    print("provider set year to $year");
    this.year = year;
    setIndex(DateTime.now().year - year);
    updateData();

    if (notify) notifyListeners();
  }

  void setIndex(int index) {
    this.index = index;
  }

  @override
  void dispose() {
    print("yearPageSTateProvider disposed");
  }
}
