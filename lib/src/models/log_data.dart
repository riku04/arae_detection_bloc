
import 'package:latlong/latlong.dart';

class LogData {

  int distance = 10;
  List<List<LatLng>> areas = List();
  List<DatePoint> datePoints = List();


}

class DatePoint {

  DateTime _dateTime;
  LatLng _point;

  DatePoint(DateTime dateTime, LatLng point){
    this._dateTime = dateTime;
    this._point = point;
  }

  DateTime getDateTime(){
    return this._dateTime;
  }

  LatLng getPoint(){
    return this._point;
  }

}