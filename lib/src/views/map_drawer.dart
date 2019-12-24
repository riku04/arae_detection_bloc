import 'package:flutter/material.dart';

class MapDrawer extends StatefulWidget{
  @override
  _MapDrawerState createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer>{

  @override
  void initState() {
    super.initState();
  }

  @override
  build(BuildContext context){
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 66,
            child: DrawerHeader(
              child: Column(
                children: <Widget>[
                  Text("Group:"),
                  Text("User:")
                ],
              ),
            ),
          ),
          Divider(),
          Text("c"),
          Text("d"),
          Text("e")
        ],
      ),
    );
  }
}