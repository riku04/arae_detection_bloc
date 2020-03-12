import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/mocks/mock_area_repository.dart';
import 'package:flutter_map_app/src/mocks/mock_user_settings_repository.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong/latlong.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  group("MapBloc", () {
    MapBloc bloc;
    setUp(() {
      bloc = MapBloc(null,MockAreaRepository(),MockUserSettingsRepository());
    });

    Polygon polygon = Polygon(points: [
      LatLng(0.0, 0.0),
      LatLng(0.0, 4.0),
      LatLng(4.0, 4.0),
      LatLng(4.0, 0.0)
    ]);

    test("polygonContainsPoint(Polygon, LatLng) expect true", () {
      LatLng point = LatLng(2.0, 2.0);
      expect(bloc.polygonContainsPoint(polygon, point), true);
    });

    test("polygonContainsPoint(Polygon, LatLng) expect true", () {
      LatLng point = LatLng(4.0, 4.0);
      expect(bloc.polygonContainsPoint(polygon, point), true);
    });

    test("polygonContainsPoint(Polygon, LatLng) expect false", () {
      LatLng point = LatLng(5.0, 5.0);
      expect(bloc.polygonContainsPoint(polygon, point), false);
    });
  });
}
