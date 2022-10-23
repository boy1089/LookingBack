

import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:glob/glob.dart';

class SensorDataManager {

  Map sensorDataAll = {};
  List<String> dates = [];
  SensorDataManager(){
  }

  Future<String?> get _localPath async {
    final directory2 = await getExternalStorageDirectories();
    var path = directory2?[0].path;
    return path;
  }

  Future<List<File>> getFiles() async {
    String? kRoot = await _localPath;
    FileManager fm = FileManager(root: Directory('$kRoot/processedSensorData')); //
    Future<List<File>> files = fm.filesTree(
      extensions: [".csv"],
    );
    return files;
  }

  Future<Map> readFiles() async {
    List<File> files = await getFiles();
    print("sensorDataManager, readFiles : $files");
    sensorDataAll = {};
    dates = [];
    for (int i = 0; i < files.length; i++) {
      var sensorData = await openFile(files.elementAt(i).path);
      print('readFiles, $i th data');
      String date = files[i].path.split('/').last.substring(0, 8);
      sensorDataAll[date] = (sensorData);
      dates.add(date);
    }
    print("sensorDataManager, readFiles done");
    return sensorDataAll;
  }

  Future<List> openFile(String date) async {
    final Directory? directory = await getExternalStorageDirectory();

    File f = File("${directory?.path}/sensorData/${date}_sensor.csv");

    if (!await f.exists()){
      return [[]];
    }

    print("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    return fields;
  }
  void writeSensorData(date, sensorData) async {
    final Directory? directory = await getExternalStorageDirectory();

    final String folder = '${directory?.path}/processedSensorData';
    bool isFolderExists = await Directory(folder).exists();
    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    final File file =
    File('$folder/${date}_processedSensor.csv');
    print("writing Cache to Local..");

    print("writing sensor data : $sensorData");
    // await file.writeAsString('time,longitude,latitude,accelX,accelY,accelZ\n', mode: FileMode.write);
    await file.writeAsString('', mode: FileMode.write);

    for (int i = 0; i < sensorData.length; i++) {
      String time = sensorData[i][0].toString();
      String longitude = sensorData[i][1].toString();
      String latitude = sensorData[i][2].toString();
      String accelX = sensorData[i][3].toString();
      String accelY = sensorData[i][4].toString();
      String accelZ = sensorData[i][5].toString();

      await file.writeAsString(
          '${time},${longitude},$latitude,$accelX,$accelY,$accelZ\n',
          mode: FileMode.append);
    }
  }

}