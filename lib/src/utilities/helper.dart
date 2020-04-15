import 'dart:math';

import 'package:latlong/latlong.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';


class Helper {
  static String stringJoiner(List<String> list, String delimiter) {
    String string = "";
    list.forEach((name) {
      string += name + delimiter;
    });
    string = string.substring(0, string.length - 1);
    return string;
  }

  static Future<String> asyncPointsToString(List<LatLng> points)async{
    String polyStr = "";
    points.forEach((point) {
      polyStr += '${point.latitude.toString()},${point.longitude.toString()},';
    });
    polyStr = polyStr.substring(0, polyStr.length - 1);
    return polyStr;
  }

  static String pointsToString(List<LatLng> points) {
    String polyStr = "";
    points.forEach((point) {
      polyStr += '${point.latitude.toString()},${point.longitude.toString()},';
    });
    polyStr = polyStr.substring(0, polyStr.length - 1);

    return polyStr;
  }

  static List<LatLng> stringToPoints(String polyStr) {
    List<String> pointStrList = polyStr.split(",");
    List<LatLng> points = List();
    for (int i = 0; i <= pointStrList.length - 2; i += 2) {
      points.add(LatLng(
          double.parse(pointStrList[i]), double.parse(pointStrList[i + 1])));
    }
    return points;
  }

  static int bytesToInteger(List<int> bytes) {
    var value = 0;
    for (var i = 0, length = bytes.length; i < length; i++) {
      value += bytes[i] * pow(256, i);
    }
    return value;
  }

  static Uint8List intTo8BytesArray(int value){
    final list = Uint64List.fromList([value]);
    final bytes = Uint8List.view(list.buffer);
    return bytes;
  }

  Future<bool> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      return false;
    } else {
      prefs.setBool('seen', true);
      return true;
    }
  }

}
