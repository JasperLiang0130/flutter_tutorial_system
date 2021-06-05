import 'dart:typed_data';
import 'package:assignment4/studentDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'calculator.dart';
import 'cameraController.dart';
import 'models.dart';
import 'dart:io';
import 'dart:convert';
import 'calculator.dart';
import 'package:camera/camera.dart';
import 'dart:async';

import 'models.dart';

class SchemeListPage extends StatefulWidget
{
  @override
  _SchemePageState createState() => _SchemePageState();
}

class _SchemePageState extends State<SchemeListPage> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var schemesLength;

  @override
  Widget build(BuildContext context) {
    return Consumer<AllModels>(
        builder: buildSchemesScaffod,
    );
  }

  Future<void> showAddSchemeDialog(BuildContext context) async {
    bool _uploading = false;

    showDialog(context: context,
      builder: (context) {

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Week "+(schemesLength+1).toString()),
                  //dropdown list
                  //extra (need to be hidden)
                ],
              ),
            ),
            actions: <Widget>[

            ],
          );
        });
      }
    );
  }

  Scaffold buildSchemesScaffod(BuildContext context, AllModels allModels, _) {

    var calcuate = Calculator();
    List<Student> students = allModels.stuItems;
    schemesLength = allModels.schItems.length;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (allModels.loading) CircularProgressIndicator() else
              Expanded(
                child: ListView.builder(
                    itemBuilder: (_, index) {
                      var scheme = allModels.schItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 16,
                        color: Colors.white,
                        shadowColor: Colors.black38,
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.list, size: 36,),
                            ],
                          ),
                          title: Text("Week "+ scheme.week.toString(), style: TextStyle(fontSize: 16)),
                          subtitle: Text(transferSchemeTypeName(scheme), style: TextStyle(fontSize: 14)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(calcuate.calculateClassAvg(scheme, students), style: TextStyle(fontSize: 18)),
                              Text("Class Avg",
                                  style: TextStyle(fontSize: 12))
                            ],
                          ),

                        ),
                      );
                    },
                    itemCount:  allModels.schItems.length,
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showAddSchemeDialog(context);
        },
        tooltip: 'Add Tutorial',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );

  }

  String transferSchemeTypeName(Scheme scheme){
    switch(scheme.type){
      case "level_HD":
        return "HD+/HD/DN/CR/PP/NN";
      case "level_A":
        return "A/B/C/D/F";
      case "attendance":
        return "Attend/Absent";
      case "score":
        return "Score of "+scheme.extra;
      case "checkbox":
        return "Checkbox of "+scheme.extra;
      return "";
    }
  }

}
