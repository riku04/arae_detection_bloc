import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:latlong/latlong.dart';

class MapScreen extends StatelessWidget{
  @override
  build(BuildContext context){
    final blocMap = BlocProvider.of<MapBloc>(context);
    final _mapController = MapController();

    blocMap.initMap();

    return Scaffold(
      body: Container(
        child: StreamBuilder<MapOptions>(
          stream: blocMap.onInitOptions,
          builder: (context, optionsSnapshot){
            return StreamBuilder<List<Marker>>(
             stream: blocMap.onAddMarker,
             builder: (context, markersSnapshot){
               return FlutterMap(
                 options: optionsSnapshot.data,
                 mapController: _mapController,
                 layers: [
                   TileLayerOptions(
                       urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                       subdomains: ['a', 'b', 'c']
                   ),
                   MarkerLayerOptions(
                     markers: markersSnapshot.data ,
                   )
                 ],
               );
             },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          label: Text("add"),
          onPressed: () {
            blocMap.addPoint.add(new LatLng(35.691075, 139.767828));
          }
      ),
    );
  }
}