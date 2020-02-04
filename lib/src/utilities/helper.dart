import 'package:latlong/latlong.dart';

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
}
