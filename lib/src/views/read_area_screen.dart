import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/read_area_bloc.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';


class ReadAreaScreen extends StatefulWidget{

  @override
  _ReadAreaScreenState createState() => _ReadAreaScreenState();
}

class _ReadAreaScreenState extends State<ReadAreaScreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  build(BuildContext context){
    final blocMap = BlocProvider.of<MapBloc>(context);
    final readAreaBloc = BlocProvider.of<ReadAreaBloc>(context);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("READ AREA"),
          ),
          body: StreamBuilder<List<String>>(
            stream: readAreaBloc.onAreaList,
            builder: (context,areaSnapshot){
              if(!areaSnapshot.hasData){
                return Scaffold();
              }
              return ListView.builder(
                itemBuilder: (BuildContext context, int index){
                  return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SpaceBox(height: 2.0,),
                        Row(
                          children: <Widget>[
                            SpaceBox(width: 5.0,),
                            OutlineButton(
                              child: Padding(
                              child: Text(
                                areaSnapshot.data[index],
                                style: TextStyle(fontSize: 22.0),
                              ),
                                padding: EdgeInsets.all(15.0),
                              ),
                              onPressed: (){
                                print("area name pressed:"+ areaSnapshot.data[index]);
                                blocMap.readSavedArea(areaSnapshot.data[index]);
                                Navigator.of(context).pop();
                                },
                            ),
                            SpaceBox(width: 5.0,),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text("領域データ削除"),
                                      content: Text(areaSnapshot.data[index]+"を削除します"),
                                      actions: <Widget>[
                                        // ボタン領域
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        FlatButton(
                                          child: Text("OK"),
                                          onPressed: (){
                                            print("delete pressed:"+ areaSnapshot.data[index]);
                                            blocMap.removeAreaByAreaName(areaSnapshot.data[index]).then((_){
                                              readAreaBloc.updateAreaList();
                                            });
                                            Navigator.pop(context);
                                            },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                        ],
                        ),
                        SpaceBox(height: 2.0)
                      ]);
                  },
                itemCount: areaSnapshot.data.length,
              );
            },
          ),
        )
    );
  }
}