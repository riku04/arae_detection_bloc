import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';

class Area {
  String areaPointsStr;

  Area({@required this.areaPointsStr});

  Area.toJson(Map<String, dynamic> json) : areaPointsStr = json['points'];

  Map<String, dynamic> toJson() => {
        'points': areaPointsStr,
      };


}
