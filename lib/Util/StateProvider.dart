
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';


class NavigationIndexProvider with ChangeNotifier{
  int navigationIndex = 0;
  String date = formatDate(DateTime.now());
  Map summaryOfGooglePhotoData = {};
  double zoomInAngle = 0.0;

  void setNavigationIndex(int index){
    navigationIndex = index;
    print("index : $navigationIndex");
    notifyListeners();
  }
  void setDate(DateTime date){
    this.date = formatDate(date);
    print("date : ${this.date}");
  }

  void setSummaryOfGooglePhotoData(data){
    summaryOfGooglePhotoData = data;
  }

  void setZoomInRotationAngle(angle){
    print("provider set zoomInAngle to $angle");
    zoomInAngle = angle;
  }

}