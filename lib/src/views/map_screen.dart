import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';

class MapScreen extends StatefulWidget{
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>{
  MapController _mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
  }

  @override
  build(BuildContext context){
    final blocMap = BlocProvider.of<MapBloc>(context);

    blocMap.initLayers();
    blocMap.initMapOptions();

    return Scaffold(
      body: Container(
        child: StreamBuilder<MapOptions>(
          stream: blocMap.onInitOptions,
          builder: (context, optionsSnapshot){
            return StreamBuilder<List<LayerOptions>>(
             stream: blocMap.onLayersChanged,
             builder: (context, layersSnapshot){
               return FlutterMap(
                 options: optionsSnapshot.data,
                 mapController: _mapController,
                 layers: layersSnapshot.data,
               );
             },
            );
          },
        ),
      ),
      floatingActionButton: Row(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: "add",
              backgroundColor: Colors.redAccent,
              label: Text("add"),
              onPressed: () {
                blocMap.addPoint.add(_mapController.center);
              }
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton.extended(
              heroTag: "ok",
                backgroundColor: Colors.yellow,
                label: Text("ok"),
                onPressed: (){
                  blocMap.createPolygon();
                },
            ),
          ),
        ],
      )
    );
  }
}