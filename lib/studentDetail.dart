import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'models.dart';
import 'models.dart';


class StudentDetail extends StatefulWidget{

  final String pk;

  const StudentDetail({Key key, this.pk}) : super(key: key);

  @override
  _StudentDetailState createState() => _StudentDetailState();

}

class _StudentDetailState extends State<StudentDetail>{

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final stuIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var students = Provider.of<AllModels>(context, listen: false).schItems;
    var schemes = Provider.of<AllModels>(context, listen: false).schItems;
    var student = Provider.of<AllModels>(context, listen: false).getStudent(widget.pk);

    nameController.text = student.name;
    stuIdController.text = student.id;
    Uint8List bytes = Base64Decoder().convert(student.img);

    //get dynamic widget
    List<Widget> _getGradeLists(List<String> grades){
      List listings = List<Widget>();
      for(int i =0; i< schemes.length; i++){
        switch(schemes[i].type){
          case "level_HD":
            final List<String> items = <String>["HD+", "HD", "DN", "CR", "PP", "NN"];
            String dropdownValue = grades[schemes[i].week-1];
            listings.add(DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 14,
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 1,
                  color: Colors.deepOrange,
                ),
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String newValue){
                  print("new value: "+newValue);
                  setState(() {
                    dropdownValue = newValue;
                  });
                  print("dropdownValue: "+dropdownValue);
                }
              )
            );
            break;
          case "level_A":
            listings.add(Text("hello"));
            break;
          case "attendance":
            listings.add(Text("att forfun"));
            break;
          case "checkbox":
            listings.add(Text("check booo"));
            break;
          case "score":
            listings.add(Text("jk rolling"));
            break;
          default:
            break;
        }
      }

        return listings;
    }

    return StatefulBuilder(builder: (context, setState){
      return Scaffold(
          appBar: AppBar(
            title: Text("Edit Student Mark"),
          ),
          body: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  padding: EdgeInsets.only(left: 5.0,
                                      right: 5.0),
                                  child: Image.memory(bytes,
                                      fit: BoxFit.contain, width: 65),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student Name"),
                                              controller: nameController,
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student ID"),
                                              controller: stuIdController,
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Column(
                                children: _getGradeLists(student.grades),
                              ),
                            ),
                            ElevatedButton.icon(onPressed: () {
                              if (_formKey.currentState.validate()) {
                                //return to previous screen
                                Navigator.pop(context);
                              }
                            },
                                icon: Icon(Icons.save),
                                label: Text("Save Values"))
                          ],
                        ),
                      ),
                    )
                  ]
              )
          )
      );
    });
  }

}

