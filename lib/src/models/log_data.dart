
import 'package:latlong/latlong.dart';

class LogData {

  int distance = 10;
  List<List<LatLng>> areas = List();
  List<DatePoint> datePoints = List();


}

class DatePoint {

  DateTime _dateTime;
  LatLng _point;
  int _status;

  DatePoint(DateTime dateTime, LatLng point, int status){
    this._dateTime = dateTime;
    this._point = point;
    this._status = status;
  }

  DateTime getDateTime(){
    return this._dateTime;
  }

  LatLng getPoint(){
    return this._point;
  }

  int getStatus(){
    return this._status;
  }

}