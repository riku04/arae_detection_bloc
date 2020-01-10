import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong/latlong.dart';

void main(){
  group("Area", () {

    List<LatLng> points = [
      LatLng(1.1,1.2),
      LatLng(2.1,2.2),
      LatLng(3.1,3.2),
      LatLng(4.1,4.2)
    ];

    String pointsString = "1.1,1.2,2.1,2.2,3.1,3.2,4.1,4.2";

    test("pointsToString(List<LatLng> points)", (){
      expect(Area.pointsToString(points), pointsString);
    });

    test("stringToPoints(String polyStr)", (){
      expect(Area.stringToPoints(pointsString), points);
    });

  });
}