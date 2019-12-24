import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';

class Area {
  String areaPoints;

  Area({
    @required this.areaPoints
  });

  Area.toJson(Map<String,dynamic> json)
    :areaPoints = json['points'];

  Map<String,dynamic> toJson() =>
      {
        'points': areaPoints,
      };

  static String pointsToString(List<LatLng> points){
    String polyStr = "";
    points.forEach((point){
      polyStr+=point.latitude.toString();
      polyStr+=",";
      polyStr+=point.longitude.toString();
      polyStr+=",";
    });
    polyStr = polyStr.substring(0,polyStr.length-1);

    return polyStr;
  }

  static List<LatLng> stringToPolygon(String polyStr){
    List<String> pointStrList = polyStr.split(",");
    List<LatLng> points = List();
    for(int i=0; i<=pointStrList.length-2; i+=2){
      points.add(
          LatLng(double.parse(pointStrList[i]),
                  double.parse(pointStrList[i+1]))
      );
    }
    return points;
  }

}