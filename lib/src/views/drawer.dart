import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';

class MainDrawer extends StatefulWidget{
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>{
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  build(BuildContext context){
    final blocMap = BlocProvider.of<MapBloc>(context);

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
          FlatButton(
            child: Row(
                children:[
                  SpaceBox(width: 16),
                  Icon(Icons.save),
                  SpaceBox(width: 64),
                  Text("SAVE AREA")
                ]
            ),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text("input area name"),
                    content: TextField(
                      controller: _textFieldController,
                    ),
                    
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed:(){
                          if(_textFieldController.text.isEmpty){
                            return;
                          }
                          print("area saved:"+_textFieldController.text);
                          blocMap.saveCurrentArea(_textFieldController.text);
                          _textFieldController.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                      
                      FlatButton(
                        child: Text("CANCEL"),
                        onPressed: (){
                          _textFieldController.clear();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                }
              );
            },
          ),
          FlatButton(
            child: Row(
                children:[
                  SpaceBox(width: 16),
                  Icon(Icons.open_in_new),
                  SpaceBox(width: 64),
                  Text("READ AREA")
                ]
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/read-area-screen');
            },
          ),
          FlatButton(
            child: Row(
                children:[
                  SpaceBox(width: 16),
                  Icon(Icons.delete),
                  SpaceBox(width: 64),
                  Text("REMOVE ALL AREAS")
                ]
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text("remove all areas?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed:(){
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text("OK"),
                          onPressed: (){
                            blocMap.removeAllPolygons();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  }
              );
            },
          ),
        ],
      ),
    );
  }
}